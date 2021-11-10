import Cocoa
class UATableCellView: NSTableCellView
{
    let myField  = UATextField(frame: NSRect())

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.initialize()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func initialize(){
        //カスタムテキストフィールドの追加
        self.addSubview(myField)
        //レイアウトの調整
        myField.translatesAutoresizingMaskIntoConstraints = false
        myField.widthAnchor.constraint(equalTo: self.widthAnchor, constant: 0).isActive = true
        myField.heightAnchor.constraint(equalTo: self.heightAnchor, constant: 0).isActive = true
    }
}
