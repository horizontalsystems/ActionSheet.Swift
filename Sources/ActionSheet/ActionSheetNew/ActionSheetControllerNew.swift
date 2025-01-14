import Foundation
import UIKit
import SnapKit
import UIExtensions

public class ActionSheetControllerNew: UIViewController, IDeinitDelegate {
    public var onDeinit: (() -> ())?

    private let content: UIViewController
    private weak var viewDelegate: ActionSheetViewDelegate?
    weak var interactiveTransitionDelegate: InteractiveTransitionDelegate?

    private let configuration: ActionSheetConfiguration

    private var keyboardHeight: CGFloat = 0 {
        didSet {
            keyboardHeightInitialized = true
        }
    }

    private var keyboardHeightInitialized = false
    private var didAppear = false
    private var dismissing = false

    private var animator: ActionSheetAnimator?
    private var ignoreByInteractivePresentingBreak = false

    private var savedConstraints: [NSLayoutConstraint]?

    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    public init(content: UIViewController, configuration: ActionSheetConfiguration) {
        self.content = content

        if let viewDelegate = content as? ActionSheetViewDelegate {
            self.viewDelegate = viewDelegate
        }
        self.configuration = configuration

        super.init(nibName: nil, bundle: nil)

        let animator = ActionSheetAnimator(configuration: configuration)
        self.animator = animator
        transitioningDelegate = animator
        animator.interactiveTransitionDelegate = self
        viewDelegate?.actionSheetView = self

        if let interactiveTransitionDelegate = content as? InteractiveTransitionDelegate {
            self.interactiveTransitionDelegate = interactiveTransitionDelegate
        }
        modalPresentationStyle = .custom

        NotificationCenter.default.addObserver(self,
                selector: #selector(keyboardNotification(notification:)),
                name: UIResponder.keyboardWillChangeFrameNotification,
                object: nil)
    }

    public override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        false
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        if configuration.tapToDismiss {
            let tapView = ActionSheetTapView()
            view.addSubview(tapView)
            tapView.snp.makeConstraints { maker in
                maker.edges.equalToSuperview()
            }
            tapView.handleTap = { [weak self] in
                self?.dismissing = true
                self?.dismiss(animated: true)
            }
        }

        // add and setup content as child view controller
        addChildController()
    }

    // lifecycle
    public override func viewWillAppear(_ animated: Bool) {
        if let savedConstraints = savedConstraints {
            view.superview?.addConstraints(savedConstraints)
        }

        dismissing = false
        super.viewWillAppear(animated)

        if !ignoreByInteractivePresentingBreak {
            content.beginAppearanceTransition(true, animated: animated)
        }

        if keyboardHeightInitialized {
            setContentViewPosition(animated: true)
        }
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !ignoreByInteractivePresentingBreak {
            content.endAppearanceTransition()
        }
        ignoreByInteractivePresentingBreak = false
        didAppear = true
    }

    public override func viewWillDisappear(_ animated: Bool) {
        dismissing = true
        savedConstraints = view.superview?.constraints

        let interactiveTransitionStarted = animator?.interactiveTransitionStarted ?? false

        if !(configuration.ignoreInteractiveFalseMoving && interactiveTransitionStarted) {
            content.beginAppearanceTransition(false, animated: animated)
        }
        super.viewWillDisappear(animated)
    }

    public override func viewDidDisappear(_ animated: Bool) {
        content.endAppearanceTransition()
        super.viewDidDisappear(animated)

        didAppear = false
    }

    @objc private func keyboardNotification(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }

        let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        let endFrameY = endFrame?.origin.y ?? 0

        if endFrameY >= UIScreen.main.bounds.size.height {
            keyboardHeight = 0
        } else {
            keyboardHeight = endFrame?.size.height ?? 0.0
        }
    }

    deinit {
        onDeinit?()
        removeChildController()
        NotificationCenter.default.removeObserver(self)
    }

}

// Child management
extension ActionSheetControllerNew {

    private func addChildController() {
        addChild(content)
        view.addSubview(content.view)
        setContentViewPosition(animated: false)
        content.view.clipsToBounds = true
        content.view.cornerRadius = configuration.cornerRadius
    }

    private func removeChildController() {
        content.removeFromParent()
        content.view.removeFromSuperview()
    }

    func setContentViewPosition(animated: Bool) {
        guard !dismissing, content.view.superview != nil else {
            return
        }

        content.view.snp.remakeConstraints { maker in
            maker.leading.trailing.equalToSuperview().inset(configuration.sideMargin)
            if configuration.style == .sheet {      // content controller from bottom of superview
                maker.top.equalToSuperview()
                maker.bottom.equalToSuperview().inset(configuration.sideMargin + keyboardHeight).priority(.required)
            } else {                                // content controller by center of superview
                maker.centerX.equalToSuperview()
                maker.centerY.equalToSuperview().priority(.low)
                maker.bottom.lessThanOrEqualTo(view.snp.bottom).inset(keyboardHeight + 16)
            }
            if let height = viewDelegate?.height {
                maker.height.equalTo(height)
            }
        }
        if let superview = view.superview {
            if animated && didAppear {
                UIView.animate(withDuration: configuration.presentAnimationDuration) { () -> Void in
                    superview.layoutIfNeeded()
                }
            } else {
                view.layoutIfNeeded()
            }
        }
    }

}

extension ActionSheetControllerNew: ActionSheetView {

    public func contentWillDismissed() {
        dismissing = true
    }

    public func dismissView(animated: Bool) {
        DispatchQueue.main.async {
            self.dismiss(animated: animated)
        }
    }

    public func didChangeHeight() {
        setContentViewPosition(animated: true)
    }

}

extension ActionSheetControllerNew: InteractiveTransitionDelegate {

    public func start(direction: TransitionDirection) {
        interactiveTransitionDelegate?.start(direction: direction)
        dismissing = direction == .dismiss
    }

    public func move(direction: TransitionDirection, percent: CGFloat) {
        interactiveTransitionDelegate?.move(direction: direction, percent: percent)
    }

    public func end(direction: TransitionDirection, cancelled: Bool) {
        if direction == .dismiss, cancelled {
            dismissing = false
        }

        interactiveTransitionDelegate?.end(direction: direction, cancelled: cancelled)
        guard configuration.ignoreInteractiveFalseMoving else {
            return
        }
        if cancelled {
            ignoreByInteractivePresentingBreak = true
        } else {
            content.beginAppearanceTransition(false, animated: true)
            viewDelegate?.didInteractiveDismissed()
        }
    }

    public func fail(direction: TransitionDirection) {
        interactiveTransitionDelegate?.fail(direction: direction)
    }

}

extension ActionSheetControllerNew {

    override open var childForStatusBarStyle: UIViewController? {
        content
    }

    override open var childForStatusBarHidden: UIViewController? {
        content
    }

}

@available(iOS 13.0, *)
extension ActionSheetControllerNew: UIAdaptivePresentationControllerDelegate {
    public func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        self.presentationController?.delegate?.presentationControllerShouldDismiss?(presentationController) ?? false
    }

    public func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        dismissing = true
        self.presentationController?.delegate?.presentationControllerWillDismiss?(presentationController)
    }

    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        dismissing = false
        self.presentationController?.delegate?.presentationControllerDidDismiss?(presentationController)
    }

    public func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        self.presentationController?.delegate?.presentationControllerDidAttemptToDismiss?(presentationController)
    }
}
