import UIKit
import SnapKit
import SectionsTableView
import ActionSheet

class SectionsViewController: UIViewController, SectionsDataSource {
    private let titleLabel = UILabel()
    private let tableView = SelfSizedSectionsTableView(style: .grouped)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black

        tableView.registerCell(forClass: UITableViewCell.self)
        tableView.sectionDataSource = self
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .clear
        tableView.delaysContentTouches = false

        view.addSubview(titleLabel)
        view.addSubview(tableView)

        titleLabel.snp.makeConstraints { maker in
            maker.top.equalToSuperview().offset(16)
            maker.leading.trailing.equalToSuperview().inset(16)
        }
        titleLabel.textColor = .white
        titleLabel.font = .boldSystemFont(ofSize: 17)
        titleLabel.textAlignment = .center
        titleLabel.text = "Swipe Here in Title"

        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        tableView.snp.makeConstraints { maker in
            maker.top.equalTo(titleLabel.snp.bottom).offset(8)
            maker.leading.trailing.equalToSuperview()
            maker.bottom.equalTo(view.safeAreaLayoutGuide).inset(24)
        }

        tableView.alwaysBounceVertical = false
        reload()
    }

    private func reload() {
        tableView.reload()
    }

    func buildSections() -> [SectionProtocol] {
        var sections = [SectionProtocol]()
        var rows = [RowProtocol]()

        for i in 0..<Int.random(in: 5...20) {
            let sendButtonRow = Row<UITableViewCell>(id: "indexed_row", height: 44, bind: { cell, _ in
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
                cell.textLabel?.text = "Row number #\(i)"
                cell.textLabel?.textColor = .white
            }, action: { [weak self] cell in
                self?.onRowTap()
            })
            rows.append(sendButtonRow)
        }

        sections.append(Section(id: "section", rows: rows))
        return sections
    }

    private func onRowTap() {
        print("Cell tapped")
        // to dismiss child with tableView must do it using async.
        DispatchQueue.main.async {
            self.dismiss(animated: true)
        }
    }

}
/*

extension SectionsViewController: ActionSheetViewDelegate {

    //  Access to actionSheetController
    var actionSheetView: ActionSheetView?

    // Static height for controller without constraints
    public var height: CGFloat? {
        320
    }

}*/
