import Cocoa
class UATableRowView: NSTableRowView
{
    var recoedWidth: CGFloat = 0
    convenience init(width: CGFloat) {
        self.init()
        recoedWidth = width
    }
    override func drawSelection(in dirtyRect: NSRect) {
        //選択行の色の設定
        let path = NSBezierPath.init(rect: NSRect(x: 0, y: 0, width: recoedWidth, height: self.bounds.height))
        NSColor.blue.set()
        path.fill()
        path.stroke()
     }
}
