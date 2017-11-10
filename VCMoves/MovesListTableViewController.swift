import UIKit

public enum MovesExample {
  case fadeIn
  case slideUpWithContext
  
  var title: String {
    switch self {
    case .fadeIn:
      return "Fade In"
    case .slideUpWithContext:
      return "Slide Up with Context"
    }
  }
}

public class MovesListTableViewController: UITableViewController {
  
  var moves: [MovesExample] = [
    .fadeIn,
    .slideUpWithContext
  ]
  
  public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let moveForSelectedRow = self.moves[indexPath.row]
    switch moveForSelectedRow {
    case .fadeIn:
      let vc = storyboard!.instantiateViewController(withIdentifier: "SlideUpWithContextViewController") as! SlideUpWithContextViewController
      vc.example = .fadeIn
      self.navigationController?.pushViewController(vc, animated: true)
    case .slideUpWithContext:
      let vc = storyboard!.instantiateViewController(withIdentifier: "SlideUpWithContextViewController") as! SlideUpWithContextViewController
      vc.example = .slideUpWithContext
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
