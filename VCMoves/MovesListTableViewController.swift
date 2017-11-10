import UIKit

public class MovesListTableViewController: UITableViewController {
  
  enum MovesExample {
    case fadeIn
    case centerModal
    case slideUpWithContext
    
    var title: String {
      switch self {
      case .fadeIn:
        return "Fade In"
      case .centerModal:
        return "Center Modal"
      case .slideUpWithContext:
        return "Slide Up with Context"
      }
    }
  }
  
  var moves: [MovesExample] = [
    .fadeIn,
    .centerModal,
    .slideUpWithContext
  ]
  
  public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let moveForSelectedRow = self.moves[indexPath.row]
    switch moveForSelectedRow {
    case .fadeIn:
      break
    case .centerModal:
      break
    case .slideUpWithContext:
      let vc = storyboard!.instantiateViewController(withIdentifier: "SlideUpWithContextViewController")
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }
  
  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    if #available(iOS 11.0, *) {
      navigationController?.navigationItem.largeTitleDisplayMode = .never
    }
  }
  
  public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return moves.count
  }
  
  public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)
    let moveForThisRow = self.moves[indexPath.row]
    cell.textLabel?.text =  moveForThisRow.title
    return cell
  }
}
