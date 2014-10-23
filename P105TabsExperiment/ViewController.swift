
import UIKit

class ViewController: UIViewController
{
    override func viewDidAppear(animated: Bool) {
        let viewController = TabsViewController()
        presentViewController(viewController, animated: false, completion: nil)
    }
}
