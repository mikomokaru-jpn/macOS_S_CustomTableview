import Cocoa
//------------------------------------------------------------------------------
// 列見出し
//------------------------------------------------------------------------------
class UATableHeaderCell: NSTableHeaderCell
{
    var needSort: Bool = false
    var order: Int = 0
    let fillColor = NSColor.lightGray
    let borderColor = NSColor.black
    
    override init(textCell string: String) {
        super.init(textCell: string)
    }
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        //セルの塗りつぶし
        let path = NSBezierPath(rect: cellFrame)
        fillColor.set()
        path.fill()
        //セルの下線
        var from = CGPoint(x: cellFrame.origin.x,
                           y: cellFrame.origin.y + cellFrame.height)
        var to = CGPoint(x: cellFrame.origin.x + cellFrame.width,
                         y: cellFrame.origin.y + cellFrame.height)
        let path2 = NSBezierPath()
        borderColor.set()
        path2.lineWidth = 1
        path2.move(to: from)
        path2.line(to: to)
        path2.stroke()
        if identifier == nil {
            return
        }
        //セルの右線
        from = CGPoint(x: cellFrame.origin.x + cellFrame.width,
                       y: cellFrame.origin.y)
        to =   CGPoint(x: cellFrame.origin.x + cellFrame.width,
                       y: cellFrame.origin.y + cellFrame.height)
        let path3 = NSBezierPath()
        NSColor.gray.set()
        path3.lineWidth = 1
        path3.move(to: from)
        path3.line(to: to)
        path3.stroke()
        //セルの表示
        let attribures:[NSAttributedString.Key:Any] = [.foregroundColor : NSColor.black, .font: NSFont.systemFont(ofSize: 14)]
        self.attributedStringValue = NSMutableAttributedString.init(string: stringValue, attributes: attribures)
        if needSort && order != 0{
            //昇順・降順をす示す上下矢印
            var image: NSImage?
            if order < 0{
                image = NSImage.init(named: "NSTouchBarGoUpTemplate")
            }else{
                image = NSImage.init(named: "NSTouchBarGoDownTemplate")
            }
            image!.size = NSMakeSize(12, 32) //やや変形
            //フレームを左右に２分割する
            var imageFrame = NSZeroRect
            var textFrame = NSZeroRect
            NSDivideRect(cellFrame, &textFrame, &imageFrame, cellFrame.width - image!.size.width-20, .minX)
            //右に矢印を表示
            imageFrame.origin.x += 4;
            imageFrame.size = image!.size
            image!.draw(in: imageFrame,
                       from: NSMakeRect(0, -5, image!.size.width, image!.size.height),
                       operation: .sourceOver, fraction: 1.0)
            let xPoint = cellFrame.origin.x + (textFrame.width / 2 - self.attributedStringValue.size().width / 2)
            let yPoint = cellFrame.origin.y + (textFrame.height / 2 - self.attributedStringValue.size().height / 2)
            //左に文字列を表示
            self.attributedStringValue.draw(at: NSPoint(x: xPoint, y: yPoint))
        }else{
            //ソートなし・文字列を表示
            let xPoint = cellFrame.origin.x + (cellFrame.width / 2 - self.attributedStringValue.size().width / 2)
            let yPoint = cellFrame.origin.y + (cellFrame.height / 2 - self.attributedStringValue.size().height / 2)
            self.attributedStringValue.draw(at: NSPoint(x: xPoint, y: yPoint))
            return
        }
    }
}

