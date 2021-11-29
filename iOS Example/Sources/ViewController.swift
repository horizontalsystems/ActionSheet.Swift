import UIKit
//import ActionSheet
import SnapKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let bottomSheetButton = UIButton()
        view.addSubview(bottomSheetButton)

        let alertButton = UIButton()
        view.addSubview(alertButton)

        bottomSheetButton.snp.makeConstraints { maker in
            maker.top.equalToSuperview().offset(50)
            maker.leading.equalToSuperview().offset(32)
            maker.trailing.equalTo(alertButton.snp.leading).offset(16)
            maker.height.equalTo(30)
        }

        bottomSheetButton.setTitleColor(.black, for: .normal)
        bottomSheetButton.setTitle("Sheet", for: .normal)
        bottomSheetButton.addTarget(self, action: #selector(showBottomSheet), for: .touchUpInside)


        alertButton.snp.makeConstraints { maker in
            maker.top.equalToSuperview().offset(50)
            maker.trailing.equalToSuperview().inset(32)
            maker.height.equalTo(30)
            maker.width.equalTo(bottomSheetButton.snp.width)
        }

        alertButton.setTitleColor(.black, for: .normal)
        alertButton.setTitle("Alert", for: .normal)
        alertButton.addTarget(self, action: #selector(showAlert), for: .touchUpInside)
    }

    @objc func showBottomSheet() {
        present(SectionsViewController().toBottomSheet, animated: true)
    }

    @objc func showAlert() {
        present(ContentViewController().toAlert, animated: true)
    }

}
