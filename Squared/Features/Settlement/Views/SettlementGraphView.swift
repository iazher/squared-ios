//
//  SettlementGraphView.swift
//  Squared
//

import SwiftUI

/// Draws members evenly around a circle with debts as directed edges between
/// them, and animates edge changes when `displayMode` swaps the dataset.
struct SettlementGraphView: View {
    let members: [SettlementViewModel.Member]
    let rawBalances: [Balance]
    let simplifiedBalances: [Balance]
    let displayMode: SettlementViewModel.DisplayMode
    let currentUserID: String?
    let onTapEdge: (_ fromUserID: String, _ toUserID: String, _ amount: Decimal) -> Void

    @State private var transitionStartDate: Date
    @State private var transitionFromEdges: [EdgeDatum]
    @State private var transitionToEdges: [EdgeDatum]

    init(
        members: [SettlementViewModel.Member],
        rawBalances: [Balance],
        simplifiedBalances: [Balance],
        displayMode: SettlementViewModel.DisplayMode,
        currentUserID: String?,
        onTapEdge: @escaping (_ fromUserID: String, _ toUserID: String, _ amount: Decimal) -> Void
    ) {
        self.members = members
        self.rawBalances = rawBalances
        self.simplifiedBalances = simplifiedBalances
        self.displayMode = displayMode
        self.currentUserID = currentUserID
        self.onTapEdge = onTapEdge

        // Populated here, not in onAppear: TimelineView(.animation) starts ticking
        // immediately, and onAppear fires a beat after the first render — leaving
        // these empty until then made the very first frame(s) draw with no edges
        // at all, so the whole graph visibly popped in a moment after the nodes did.
        let initialEdges = Self.edgeData(for: displayMode, rawBalances: rawBalances, simplifiedBalances: simplifiedBalances)
        _transitionFromEdges = State(initialValue: initialEdges)
        _transitionToEdges = State(initialValue: initialEdges)
        _transitionStartDate = State(initialValue: Date())
    }

    private let animationDuration: TimeInterval = 0.4
    private let nodeRadius: CGFloat = 26
    private let minEdgeWidth: CGFloat = 3
    private let maxEdgeWidth: CGFloat = 5
    private let hitTestTolerance: CGFloat = 24
    private let labelPadding: CGFloat = 6
    /// Caps how far a label can be nudged from its edge's true midpoint, so it
    /// never drifts far enough to look like it belongs to a different edge.
    private let maxLabelNudge: CGFloat = 18
    private let labelNudgeStep: CGFloat = 3
    /// Minimum angle (radians) kept between two edges attached to the same node.
    private let minAngularSeparation: CGFloat = 0.4
    private let angularNudgeStep: CGFloat = 0.05
    /// Caps how far an edge's attachment point can rotate around a node from its
    /// natural angle, so it never drifts far enough to look like it belongs to a
    /// different node's edge.
    private let maxAngularNudge: CGFloat = 0.6
    /// Muted but clearly visible against black — distinct from the current-user
    /// edges without reading as low-contrast background noise.
    private let neutralEdgeColor = Color(red: 0.62, green: 0.58, blue: 0.72).opacity(0.85)
    /// Brand gradient (#7758D1 → #F7CBFD), same one used on the "View Settlement"
    /// button — used for edges where the current user owes money.
    private let brandGradientColors = [
        Color(red: 0.4667, green: 0.3451, blue: 0.8196),
        Color(red: 0.9686, green: 0.7961, blue: 0.9922)
    ]

    struct EdgeKey: Hashable {
        let low: String
        let high: String
    }

    struct EdgeDatum {
        let key: EdgeKey
        let fromUserID: String
        let toUserID: String
        let amount: Decimal
    }

    /// Resolved curve geometry for one edge, computed once and shared by both the
    /// line-drawing pass and the label pass so they never disagree on shape.
    private struct EdgeGeometry {
        let edge: EdgeDatum
        let start: CGPoint
        let control: CGPoint
        let end: CGPoint
    }

    /// An edge's control point plus its unclamped node positions — computed
    /// before any per-node fan-out is applied to where it actually attaches.
    private struct RawEdge {
        let edge: EdgeDatum
        let from: CGPoint
        let to: CGPoint
        let control: CGPoint
    }

    private enum AttachmentSide {
        case start
        case end
    }

    /// One edge's attachment angle around a single node's circle (a node
    /// contributes one of these for each edge touching it, whether as its tail
    /// or its arrowhead), used to fan converging edges apart.
    private struct NodeAttachment {
        let edgeIndex: Int
        let side: AttachmentSide
        let naturalAngle: CGFloat
        var angle: CGFloat
    }

    /// A label's natural position plus a signed offset (along its edge's own
    /// perpendicular) used to nudge it away from other labels it collides with.
    private struct LabelSlot {
        let basePosition: CGPoint
        let perpendicular: CGVector
        let resolvedLabel: GraphicsContext.ResolvedText
        let pillSize: CGSize
        var offset: CGFloat = 0

        var position: CGPoint {
            CGPoint(x: basePosition.x + perpendicular.dx * offset, y: basePosition.y + perpendicular.dy * offset)
        }

        var rect: CGRect {
            let p = position
            return CGRect(x: p.x - pillSize.width / 2, y: p.y - pillSize.height / 2, width: pillSize.width, height: pillSize.height)
        }
    }

    var body: some View {
        GeometryReader { proxy in
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    draw(context: context, size: size, at: timeline.date)
                }
            }
            .contentShape(Rectangle())
            .accessibilityIdentifier("SettlementGraph")
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onEnded { value in
                        handleTap(at: value.location, in: proxy.size)
                    }
            )
        }
        .onChange(of: displayMode) { _, newMode in
            transitionFromEdges = interpolatedEdges(at: Date())
            transitionToEdges = edgeData(for: newMode)
            transitionStartDate = Date()
        }
    }

    // MARK: - Drawing

    private func draw(context: GraphicsContext, size: CGSize, at date: Date) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radii = graphRadii(in: size)
        let positions = nodePositions(in: size)
        let maxAmount = max(
            rawBalances.map(\.amount).max() ?? 1,
            simplifiedBalances.map(\.amount).max() ?? 1
        )

        let rawEdges: [RawEdge] = interpolatedEdges(at: date).compactMap { edge in
            guard let from = positions[edge.fromUserID], let to = positions[edge.toUserID] else { return nil }
            let dx = to.x - from.x
            let dy = to.y - from.y
            guard (dx * dx + dy * dy) > 1 else { return nil }
            let control = controlPoint(from: from, to: to, center: center, radii: radii)
            return RawEdge(edge: edge, from: from, to: to, control: control)
        }

        let attachmentAngles = fannedAttachmentAngles(for: rawEdges)

        let geometries: [EdgeGeometry] = rawEdges.enumerated().map { index, raw in
            // Trimmed toward the (possibly fanned) angle, not the straight node-to-node
            // chord, so the line departs/arrives along the curve's own direction.
            let startAngle = attachmentAngles.start[index] ?? naturalAngle(at: raw.from, toward: raw.control)
            let endAngle = attachmentAngles.end[index] ?? naturalAngle(at: raw.to, toward: raw.control)
            let start = CGPoint(x: raw.from.x + cos(startAngle) * nodeRadius, y: raw.from.y + sin(startAngle) * nodeRadius)
            let end = CGPoint(x: raw.to.x + cos(endAngle) * nodeRadius, y: raw.to.y + sin(endAngle) * nodeRadius)
            return EdgeGeometry(edge: raw.edge, start: start, control: raw.control, end: end)
        }

        // Pass 1: every edge's line + arrowhead first, so no line can later be
        // stroked on top of a label that was already drawn in an earlier edge's turn.
        for geometry in geometries {
            drawEdgeLine(context: context, geometry: geometry, maxAmount: maxAmount)
        }

        // Pass 2: all labels, positioned to avoid colliding with each other, then
        // drawn after every line so each pill fully occludes whatever's behind it.
        var slots = labelSlots(for: geometries, context: context)
        resolveLabelCollisions(&slots)
        for slot in slots {
            drawAmountLabel(context: context, slot: slot)
        }

        for member in members {
            guard let point = positions[member.id] else { continue }
            drawNode(context: context, member: member, at: point)
        }
    }

    private func drawEdgeLine(context: GraphicsContext, geometry: EdgeGeometry, maxAmount: Decimal) {
        let start = geometry.start
        let control = geometry.control
        let end = geometry.end
        let amount = geometry.edge.amount

        // Emphasize differences even among smaller amounts, not just the extremes.
        let ratio = maxAmount > 0 ? Double(truncating: (amount / maxAmount) as NSNumber) : 0
        let width = minEdgeWidth + (maxEdgeWidth - minEdgeWidth) * CGFloat(sqrt(max(0, ratio)))
        let shading = edgeShading(fromUserID: geometry.edge.fromUserID, toUserID: geometry.edge.toUserID, start: start, end: end)

        var curve = Path()
        curve.move(to: start)
        curve.addQuadCurve(to: end, control: control)
        context.stroke(curve, with: shading, style: StrokeStyle(lineWidth: width, lineCap: .round))

        // Arrow aligned to the curve's actual tangent at the endpoint, not the straight chord.
        let tangentAngle = atan2(end.y - control.y, end.x - control.x)
        let arrowLength: CGFloat = 8
        let arrowAngle: CGFloat = .pi / 7
        var arrow = Path()
        arrow.move(to: end)
        arrow.addLine(to: CGPoint(x: end.x - arrowLength * cos(tangentAngle - arrowAngle), y: end.y - arrowLength * sin(tangentAngle - arrowAngle)))
        arrow.move(to: end)
        arrow.addLine(to: CGPoint(x: end.x - arrowLength * cos(tangentAngle + arrowAngle), y: end.y - arrowLength * sin(tangentAngle + arrowAngle)))
        context.stroke(arrow, with: shading, style: StrokeStyle(lineWidth: max(2, width * 0.6), lineCap: .round))
    }

    /// The angle (around `node`) an edge would naturally attach at, with no
    /// awareness of any other edge also attached to that node.
    private func naturalAngle(at node: CGPoint, toward target: CGPoint) -> CGFloat {
        atan2(target.y - node.y, target.x - node.x)
    }

    /// Groups all edges attached to each node — tails and arrowheads together,
    /// since either can collide with the other — and nudges any that share
    /// nearly the same angle apart until they clear `minAngularSeparation`,
    /// capped at `maxAngularNudge` from each edge's true natural angle.
    private func fannedAttachmentAngles(for rawEdges: [RawEdge]) -> (start: [Int: CGFloat], end: [Int: CGFloat]) {
        var attachmentsByNode: [String: [NodeAttachment]] = [:]
        for (index, raw) in rawEdges.enumerated() {
            let startAngle = naturalAngle(at: raw.from, toward: raw.control)
            let endAngle = naturalAngle(at: raw.to, toward: raw.control)
            attachmentsByNode[raw.edge.fromUserID, default: []].append(NodeAttachment(edgeIndex: index, side: .start, naturalAngle: startAngle, angle: startAngle))
            attachmentsByNode[raw.edge.toUserID, default: []].append(NodeAttachment(edgeIndex: index, side: .end, naturalAngle: endAngle, angle: endAngle))
        }

        var resolvedStart: [Int: CGFloat] = [:]
        var resolvedEnd: [Int: CGFloat] = [:]
        for (_, var attachments) in attachmentsByNode {
            if attachments.count > 1 {
                for _ in 0..<8 {
                    var adjustedAny = false
                    for i in 0..<attachments.count {
                        for j in (i + 1)..<attachments.count {
                            let diff = normalizedAngleDifference(attachments[j].angle - attachments[i].angle)
                            guard abs(diff) < minAngularSeparation else { continue }
                            let step: CGFloat = diff >= 0 ? angularNudgeStep : -angularNudgeStep
                            let newIAngle = clampedAngle(attachments[i].angle - step, natural: attachments[i].naturalAngle)
                            let newJAngle = clampedAngle(attachments[j].angle + step, natural: attachments[j].naturalAngle)
                            if newIAngle != attachments[i].angle || newJAngle != attachments[j].angle {
                                attachments[i].angle = newIAngle
                                attachments[j].angle = newJAngle
                                adjustedAny = true
                            }
                        }
                    }
                    if !adjustedAny { break }
                }
            }
            for attachment in attachments {
                switch attachment.side {
                case .start: resolvedStart[attachment.edgeIndex] = attachment.angle
                case .end: resolvedEnd[attachment.edgeIndex] = attachment.angle
                }
            }
        }
        return (resolvedStart, resolvedEnd)
    }

    private func normalizedAngleDifference(_ angle: CGFloat) -> CGFloat {
        atan2(sin(angle), cos(angle))
    }

    private func clampedAngle(_ angle: CGFloat, natural: CGFloat) -> CGFloat {
        let diff = max(-maxAngularNudge, min(maxAngularNudge, normalizedAngleDifference(angle - natural)))
        return natural + diff
    }

    /// Builds each edge's natural label placement (position + perpendicular axis
    /// it's allowed to nudge along), before any collision resolution runs.
    private func labelSlots(for geometries: [EdgeGeometry], context: GraphicsContext) -> [LabelSlot] {
        geometries.map { geometry in
            let start = geometry.start
            let control = geometry.control
            let end = geometry.end
            let midpoint = CGPoint(
                x: 0.25 * start.x + 0.5 * control.x + 0.25 * end.x,
                y: 0.25 * start.y + 0.5 * control.y + 0.25 * end.y
            )
            // Exact quadratic-bezier identity: the tangent at t=0.5 equals (end - start).
            let tangent = CGVector(dx: end.x - start.x, dy: end.y - start.y)
            let tangentLength = hypot(tangent.dx, tangent.dy)
            let perpendicular: CGVector = tangentLength > 0
                ? CGVector(dx: -tangent.dy / tangentLength, dy: tangent.dx / tangentLength)
                : CGVector(dx: 1, dy: 0)

            let resolvedLabel = context.resolve(Text(geometry.edge.amount.formatted(currencyCode: "USD")).font(.caption2.bold()).foregroundColor(.white))
            let labelSize = resolvedLabel.measure(in: CGSize(width: 160, height: 40))
            let pillSize = CGSize(width: labelSize.width + 10, height: labelSize.height + 4)

            return LabelSlot(basePosition: midpoint, perpendicular: perpendicular, resolvedLabel: resolvedLabel, pillSize: pillSize)
        }
    }

    /// Iteratively nudges any pair of overlapping (or too-close) labels apart,
    /// each along its own edge's perpendicular, capped at `maxLabelNudge` so a
    /// label never drifts far enough to look like it belongs to another edge.
    private func resolveLabelCollisions(_ slots: inout [LabelSlot]) {
        guard slots.count > 1 else { return }
        for _ in 0..<8 {
            var adjustedAny = false
            for i in 0..<slots.count {
                for j in (i + 1)..<slots.count {
                    let rectI = slots[i].rect.insetBy(dx: -labelPadding / 2, dy: -labelPadding / 2)
                    let rectJ = slots[j].rect.insetBy(dx: -labelPadding / 2, dy: -labelPadding / 2)
                    guard rectI.intersects(rectJ) else { continue }

                    let dx = slots[j].position.x - slots[i].position.x
                    let dy = slots[j].position.y - slots[i].position.y
                    let iDot = slots[i].perpendicular.dx * dx + slots[i].perpendicular.dy * dy
                    let jDot = slots[j].perpendicular.dx * dx + slots[j].perpendicular.dy * dy
                    let iSign: CGFloat = iDot >= 0 ? -1 : 1
                    let jSign: CGFloat = jDot >= 0 ? 1 : -1

                    slots[i].offset = max(-maxLabelNudge, min(maxLabelNudge, slots[i].offset + iSign * labelNudgeStep))
                    slots[j].offset = max(-maxLabelNudge, min(maxLabelNudge, slots[j].offset + jSign * labelNudgeStep))
                    adjustedAny = true
                }
            }
            if !adjustedAny { break }
        }
    }

    private func drawAmountLabel(context: GraphicsContext, slot: LabelSlot) {
        let position = slot.position
        let pillRect = CGRect(
            x: position.x - slot.pillSize.width / 2,
            y: position.y - slot.pillSize.height / 2,
            width: slot.pillSize.width,
            height: slot.pillSize.height
        )
        context.fill(Path(roundedRect: pillRect, cornerRadius: pillRect.height / 2), with: .color(Color("CardSurface")))
        context.draw(slot.resolvedLabel, at: position)
    }

    /// A control point pulled toward the ellipse's perimeter (rather than the exact
    /// center) so edges bow outward instead of bundling through the middle — this
    /// is what keeps near-diametric chords from cluttering the center.
    private func controlPoint(from: CGPoint, to: CGPoint, center: CGPoint, radii: (x: CGFloat, y: CGFloat)) -> CGPoint {
        let midpoint = CGPoint(x: (from.x + to.x) / 2, y: (from.y + to.y) / 2)
        var dx = midpoint.x - center.x
        var dy = midpoint.y - center.y
        var length = hypot(dx, dy)
        if length < 1 {
            // Diametric chord — its midpoint IS the center, so bow perpendicular to the chord instead.
            dx = -(to.y - from.y)
            dy = to.x - from.x
            length = hypot(dx, dy)
        }
        guard length > 0 else { return midpoint }
        let controlDistance = ((radii.x + radii.y) / 2) * 0.55
        return CGPoint(x: center.x + dx / length * controlDistance, y: center.y + dy / length * controlDistance)
    }

    private func drawNode(context: GraphicsContext, member: SettlementViewModel.Member, at point: CGPoint) {
        let rect = CGRect(x: point.x - nodeRadius, y: point.y - nodeRadius, width: nodeRadius * 2, height: nodeRadius * 2)
        let glowColor = MemberAvatar.color(for: member.id)
        context.drawLayer { layerContext in
            // A dark drop shadow wouldn't read against the near-black background,
            // so this uses a soft colored glow (the node's own color) instead.
            // Kept deliberately subtle — at higher edge density, a stronger glow
            // adds fuzziness right where several edges already converge.
            layerContext.addFilter(.shadow(color: glowColor.opacity(0.45), radius: 5, x: 0, y: 0))
            layerContext.fill(Path(ellipseIn: rect), with: .color(glowColor))
        }

        let initials = context.resolve(Text(member.initials).font(.caption.bold()).foregroundColor(.white))
        context.draw(initials, at: point)

        let name = context.resolve(Text(member.displayName).font(.caption2).foregroundColor(.white.opacity(0.8)))
        context.draw(name, at: CGPoint(x: point.x, y: point.y + nodeRadius + 12))
    }

    private func edgeShading(fromUserID: String, toUserID: String, start: CGPoint, end: CGPoint) -> GraphicsContext.Shading {
        if fromUserID == currentUserID {
            return .linearGradient(
                Gradient(colors: brandGradientColors),
                startPoint: start,
                endPoint: end
            )
        } else if toUserID == currentUserID {
            return .color(Color("PositiveBalance"))
        }
        return .color(neutralEdgeColor)
    }

    // MARK: - Layout

    /// Independent horizontal/vertical radii (an ellipse, not a circle) so a tall,
    /// narrow canvas — e.g. a portrait phone screen — uses its vertical space
    /// fully instead of being capped by the tighter horizontal dimension.
    private func graphRadii(in size: CGSize) -> (x: CGFloat, y: CGFloat) {
        (max(0, size.width / 2 - 55), max(0, size.height / 2 - 45))
    }

    private func nodePositions(in size: CGSize) -> [String: CGPoint] {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radii = graphRadii(in: size)
        var positions: [String: CGPoint] = [:]
        for (index, member) in members.enumerated() {
            positions[member.id] = position(for: index, total: members.count, center: center, radii: radii)
        }
        return positions
    }

    private func position(for index: Int, total: Int, center: CGPoint, radii: (x: CGFloat, y: CGFloat)) -> CGPoint {
        guard total > 0 else { return center }
        let angle = (2 * Double.pi * Double(index) / Double(total)) - .pi / 2
        return CGPoint(x: center.x + radii.x * cos(angle), y: center.y + radii.y * sin(angle))
    }

    // MARK: - Animation

    private func edgeData(for mode: SettlementViewModel.DisplayMode) -> [EdgeDatum] {
        Self.edgeData(for: mode, rawBalances: rawBalances, simplifiedBalances: simplifiedBalances)
    }

    /// Static so `init` can compute the starting edge set before `self` (and thus
    /// the instance method above) is fully available.
    private static func edgeData(for mode: SettlementViewModel.DisplayMode, rawBalances: [Balance], simplifiedBalances: [Balance]) -> [EdgeDatum] {
        let source = mode == .raw ? rawBalances : simplifiedBalances
        return source.map { balance in
            let key = EdgeKey(low: min(balance.fromUserID, balance.toUserID), high: max(balance.fromUserID, balance.toUserID))
            return EdgeDatum(key: key, fromUserID: balance.fromUserID, toUserID: balance.toUserID, amount: balance.amount)
        }
    }

    /// Positive means `high` owes `low` (the canonical direction for this key); negative the reverse.
    private func signedAmount(_ edges: [EdgeDatum], key: EdgeKey) -> Decimal {
        guard let edge = edges.first(where: { $0.key == key }) else { return 0 }
        return edge.fromUserID == key.high ? edge.amount : -edge.amount
    }

    private func interpolatedEdges(at date: Date) -> [EdgeDatum] {
        let progress = animationProgress(at: date)
        let keys = Set(transitionFromEdges.map(\.key)).union(transitionToEdges.map(\.key))
        return keys.compactMap { key in
            let fromSigned = signedAmount(transitionFromEdges, key: key)
            let toSigned = signedAmount(transitionToEdges, key: key)
            let signed = fromSigned + (toSigned - fromSigned) * Decimal(progress)
            guard abs(signed) > 0.005 else { return nil }
            if signed > 0 {
                return EdgeDatum(key: key, fromUserID: key.high, toUserID: key.low, amount: signed)
            } else {
                return EdgeDatum(key: key, fromUserID: key.low, toUserID: key.high, amount: -signed)
            }
        }
    }

    private func animationProgress(at date: Date) -> Double {
        let elapsed = date.timeIntervalSince(transitionStartDate)
        let raw = max(0, min(1, elapsed / animationDuration))
        return raw * raw * (3 - 2 * raw) // smoothstep easing
    }

    // MARK: - Hit testing

    private func handleTap(at location: CGPoint, in size: CGSize) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radii = graphRadii(in: size)
        let positions = nodePositions(in: size)
        let edges = interpolatedEdges(at: Date())

        var closest: (edge: EdgeDatum, distance: CGFloat)?
        for edge in edges {
            guard let from = positions[edge.fromUserID], let to = positions[edge.toUserID] else { continue }
            let control = controlPoint(from: from, to: to, center: center, radii: radii)
            let distance = distanceFromPoint(location, toQuadCurveFrom: from, control: control, to: to)
            if distance < hitTestTolerance, (closest == nil || distance < closest!.distance) {
                closest = (edge, distance)
            }
        }

        if let match = closest {
            onTapEdge(match.edge.fromUserID, match.edge.toUserID, match.edge.amount)
        }
    }

    /// Approximates distance-to-curve by sampling the quadratic bezier — the edges
    /// are drawn curved, so a straight-line distance check would miss them.
    private func distanceFromPoint(_ point: CGPoint, toQuadCurveFrom start: CGPoint, control: CGPoint, to end: CGPoint) -> CGFloat {
        let sampleCount = 24
        var minDistance = CGFloat.greatestFiniteMagnitude
        var previous = start
        for step in 1...sampleCount {
            let t = CGFloat(step) / CGFloat(sampleCount)
            let sample = quadCurvePoint(start: start, control: control, end: end, t: t)
            minDistance = min(minDistance, distanceFromPoint(point, toSegmentFrom: previous, to: sample))
            previous = sample
        }
        return minDistance
    }

    private func quadCurvePoint(start: CGPoint, control: CGPoint, end: CGPoint, t: CGFloat) -> CGPoint {
        let oneMinusT = 1 - t
        let x = oneMinusT * oneMinusT * start.x + 2 * oneMinusT * t * control.x + t * t * end.x
        let y = oneMinusT * oneMinusT * start.y + 2 * oneMinusT * t * control.y + t * t * end.y
        return CGPoint(x: x, y: y)
    }

    private func distanceFromPoint(_ point: CGPoint, toSegmentFrom a: CGPoint, to b: CGPoint) -> CGFloat {
        let dx = b.x - a.x
        let dy = b.y - a.y
        let lengthSquared = dx * dx + dy * dy
        guard lengthSquared > 0 else { return hypot(point.x - a.x, point.y - a.y) }

        var t = ((point.x - a.x) * dx + (point.y - a.y) * dy) / lengthSquared
        t = max(0, min(1, t))
        let projected = CGPoint(x: a.x + t * dx, y: a.y + t * dy)
        return hypot(point.x - projected.x, point.y - projected.y)
    }
}
