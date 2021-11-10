import Cocoa

class UATextField: NSTextField
{
    var align: Align = .left  //文字列の文字揃え

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func draw(_ dirtyRect: NSRect) {
        //セルの下線
        var from = CGPoint(x: dirtyRect.origin.x,
                           y: dirtyRect.origin.y + dirtyRect.height)
        var to = CGPoint(x: dirtyRect.origin.x + dirtyRect.width,
                         y: dirtyRect.origin.y + dirtyRect.height)
        let path1 = NSBezierPath()
        NSColor.black.set()
        path1.lineWidth = 1
        path1.move(to: from)
        path1.line(to: to)
        path1.stroke()
        //セルの右線
        from = CGPoint(x: dirtyRect.origin.x + dirtyRect.width,
                       y: dirtyRect.origin.y)
        to =   CGPoint(x: dirtyRect.origin.x + dirtyRect.width,
                       y: dirtyRect.origin.y + dirtyRect.height)
        let path2 = NSBezierPath()
        path2.lineWidth = 1
        path2.move(to: from)
        path2.line(to: to)
        path2.stroke()
        //文字列の表示位置
        let y :CGFloat =  dirtyRect.size.height / 2
                       - self.attributedStringValue.size().height / 2;
        var x :CGFloat = 10
        if self.align == .center{
            x = dirtyRect.size.width / 2 - self.attributedStringValue.size().width / 2;
        }
        if self.align == .right{
            x = dirtyRect.size.width - self.attributedStringValue.size().width - 10
        }
        //文字列の表示
        self.attributedStringValue.draw(at: NSMakePoint(x, y))
    }
}
