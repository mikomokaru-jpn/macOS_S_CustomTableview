import Cocoa

//文字列の表示位置
enum Align {
    case left
    case center
    case right
}

class UATableManager: NSObject, NSTableViewDelegate, NSTableViewDataSource
{    // プロパティ
    var dataList = [[String:Any]]()
    private weak var baseView: NSView?
    private let tableView = NSTableView()
    private var selectedRowIndex: Int = 0
    //列の定義
    let definitions =
        [["id":"date", "width":160, "title": "日付", "sort": true, "fixed": false, "align": Align.center],
         ["id":"lower", "width":100, "title": "最低血圧", "sort": true, "fixed": false, "align": Align.right],
         ["id":"upper", "width":100, "title": "最高血圧", "sort": true, "fixed": false, "align": Align.right],
         ["id":"pulse", "width":70, "title": "脈圧", "sort": false, "fixed": false, "align": Align.right]]
    //セルの個別編集クロージャ
    //年月日をスラッシュで区切る
    let yearMonthDayText = { (val:Any) -> (String) in
        if let value = val as? String{
            let y = String(value.prefix(4))
            let from = value.index(value.startIndex, offsetBy:4)
            let to = value.index(value.startIndex, offsetBy:6)
            let m = String(value[from..<to])
            let d = String(value.suffix(2))
            return String(format:"%@ / %@ / %@", y, m, d)
        }
        return "?"
    }
    //イニシャライザ
    init(point: NSPoint, view: NSView) {
        super.init()
        baseView = view
        //スクロールビューの作成
        let scrollView = NSScrollView()
        scrollView.frame = NSRect(x: point.x, y: point.y , width: 600, height:507)
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        scrollView.borderType = .lineBorder
        baseView?.addSubview(scrollView)
        //テーブルビューの作成
        tableView.rowHeight = 30
        tableView.backgroundColor = NSColor.white
        tableView.intercellSpacing = NSSize(width: 0, height:0)
        tableView.headerView?.frame.size.height = 40
        tableView.dataSource = self
        tableView.delegate = self
        scrollView.documentView = tableView
        //列オブジェクトの作成
        makeColumn(id: "selector", width: 20, title: "", sort: false, fixed: true, align: .center)
        for rec in definitions{
            //型チェック
            guard let id = rec["id"] as? String  else {
                print("id Conversion error")
                return
            }
            guard let int_width = rec["width"] as? Int  else {
                print("width Conversion error")
                return
            }
            let width = CGFloat(int_width) //変換 Int -> CGFloat
            guard let title = rec["title"] as? String  else {
                print("title Conversion error")
                return
            }
            guard let sort = rec["sort"] as? Bool  else {
                print("sort Conversion error")
                return
            }
            guard let fixed = rec["fixed"] as? Bool  else {
                print("fixed Conversion error")
                return
            }
            guard let align = rec["align"] as? Align  else {
                print("align Conversion error")
                return
            }
            makeColumn(id: id, width: width, title: title, sort: sort, fixed: fixed, align: align)
        }
    }
    //列オブジェクト作成関数
    private func makeColumn(id: String, width: CGFloat, title: String, sort: Bool, fixed: Bool, align: Align){
        //Column
        let column = UATableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: id))
        column.width = width
        column.minWidth = width
        if fixed{
            column.maxWidth = width
        }
        column.align = align
        tableView.addTableColumn(column)
        //Header
        let newCell = UATableHeaderCell(textCell: "")
        newCell.identifier = NSUserInterfaceItemIdentifier(rawValue: id)
        newCell.stringValue = title
        newCell.needSort = sort
        column.headerCell = newCell
    }
    
    //NStableView DataSource
    func numberOfRows(in tableView: NSTableView) -> Int{
        return dataList.count
    }
    //NStableView DataSource
    func tableView(_ tableView: NSTableView,
                   viewFor column: NSTableColumn?,
                   row: Int) -> NSView?{
        guard let col = column as? UATableColumn else {
            return nil
        }
        let cellView: UATableCellView
        if let cv = tableView.makeView(withIdentifier: col.identifier, owner: self) as? UATableCellView{
            cellView = cv  //オブジェクトの再利用
        }else{
            cellView = UATableCellView()
            cellView.identifier = column?.identifier
            cellView.myField.align = col.align
        }
        let key = col.identifier.rawValue
        if let value = dataList[row][key] as? Int{
            //データの取得
            var text = String(value)
            //年月日をスラッシュで区切る
            if key == "date"{
               text = yearMonthDayText(text)
            }
            //セルの背景色
            cellView.myField.wantsLayer = true
            cellView.myField.layer?.backgroundColor = NSColor.white.cgColor
            //表示文字列の作成
            var font = NSFont.systemFont(ofSize: 18)
            if let newFont = NSFont(name: "HiraginoSans-W3"  , size: 16){
                font = newFont
            }
            let attribures = [NSAttributedString.Key.foregroundColor : NSColor.black,
                              NSAttributedString.Key.font: font]
            let atrString = NSMutableAttributedString(string: text, attributes: attribures)
            cellView.myField.attributedStringValue = atrString
        }
        return cellView
    }
    //列のヘッダがクリックされた
    func tableView(_ tableView: NSTableView, didClick tableColumn: NSTableColumn){
        if let columnHeader = tableColumn.headerCell as? UATableHeaderCell,
            columnHeader.needSort{
            //ソート対象の列である
            if let key = columnHeader.identifier?.rawValue{
                var orderFlg: Bool
                if columnHeader.order == 0 || columnHeader.order < 0{
                    //昇順
                    orderFlg = true
                    columnHeader.order = 1
                }else{
                    //降順
                    orderFlg = false
                    columnHeader.order = -1
                }
                tableView.tableColumns.forEach{
                    if let hCell =  $0.headerCell as? UATableHeaderCell,
                        hCell.identifier?.rawValue != key{
                        hCell.order = 0 //対象外の列の矢印を消す
                    }
                }
                dataList = dataListSorted(key: key, ascending: orderFlg, type: Int.self) //ソート
                tableView.reloadData()
                tableView.selectRowIndexes(IndexSet(integer: selectedRowIndex), byExtendingSelection: false)
            }
        }
    }
    //行の選択が変わった
    func tableViewSelectionDidChange(_ notification: Notification){
        selectedRowIndex = tableView.selectedRow
    }
    //行が選択された
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        var sum: CGFloat = 0
        _ = tableView.tableColumns.map{ sum += $0.width}
        return UATableRowView(width: sum - 1)
    }
    //最初の表示
    func firstDisplay(){
        dataList = dataListSorted(key: "date", ascending: true, type: Int.self)
        tableView.tableColumns.forEach{
            if let hCell =  $0.headerCell as? UATableHeaderCell,
                hCell.identifier?.rawValue == "date"{
                hCell.order = 1
            }
        }
        tableView.reloadData()
        tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
        baseView?.window!.makeFirstResponder(tableView)
    }
    //辞書の配列のソート・辞書の値をソートキーとする
    private func dataListSorted<T: Comparable>(key: String, ascending: Bool, type:T.Type) -> [[String:Any]]{
        return dataList.sorted {
            guard let v1 = $0[key] as? T else{
                return false
            }
            guard let v2 = $1[key] as? T else{
                return false
            }
            return  ascending ? (v1 < v2) : (v1 > v2)
        }
    }
}
