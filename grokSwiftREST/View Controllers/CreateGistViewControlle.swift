//
//  CreateGistViewControlle.swift
//  grokSwiftREST
//
//  Created by Christina Moulton on 2018-03-27.
//  Copyright © 2018 Christina Moulton. All rights reserved.
//

import Foundation
import XLForm

class CreateGistViewController: XLFormViewController {
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.initializeForm()
  }

  override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    self.initializeForm()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .cancel,
      target: self,
      action: #selector(cancelPressed(_:)))
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .save,
      target: self,
      action: #selector(savePressed(_:)))
  }

  @objc func cancelPressed(_ sender: UIBarButtonItem) {
    self.navigationController?.popViewController(animated: true)
  }

  @objc func savePressed(_ sender: UIBarButtonItem) {
    let validationErrors = self.formValidationErrors() as? [Error]
    guard validationErrors?.count == 0 else {
      self.showFormValidationError(validationErrors!.first)
      return
    }
    self.tableView.endEditing(true)

    let isPublic: Bool
    if let isPublicValue = form.formRow(withTag: "isPublic")?.value as? Bool {
      isPublic = isPublicValue
    } else {
      isPublic = false
    }

    guard let gistDescription = form.formRow(withTag: "description")?.value as? String,
      let filename = form.formRow(withTag: "filename")?.value as? String,
      let fileContent = form.formRow(withTag: "fileContent")?.value as? String else {
        print("could not get values from creation form")
        return
    }

    var files: [String: File] = [:]
    let file = File(url: nil, content: fileContent)
    files[filename] = file

    let gist = Gist(gistDescription: gistDescription, files: files, isPublic: isPublic)
    GitHubAPIManager.shared.createNewGist(gist) {
      result in
      guard result.error == nil,
        let successValue = result.value,
        successValue == true else {
          print(result.error!)
          let alertController = UIAlertController(title: "Could not create gist",
                                                  message: "Sorry, your gist couldn't be created. " +
            "Maybe GitHub is down or you don't have an internet connection.",
                                                  preferredStyle: .alert)
          // add ok button
          let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
          alertController.addAction(okAction)
          self.present(alertController, animated:true, completion: nil)
          return
      }
      let _ = self.navigationController?.popViewController(animated: true)
    }
  }

  private func initializeForm() {
    let form = XLFormDescriptor(title: "Gist")

    let section1 = XLFormSectionDescriptor.formSection() as XLFormSectionDescriptor
    form.addFormSection(section1)

    let descriptionRow = XLFormRowDescriptor(tag: "description", rowType:
      XLFormRowDescriptorTypeText, title: "Description")
    descriptionRow.isRequired = true
    section1.addFormRow(descriptionRow)

    let isPublicRow = XLFormRowDescriptor(tag: "isPublic", rowType:
      XLFormRowDescriptorTypeBooleanSwitch, title: "Public?")
    isPublicRow.isRequired = false
    section1.addFormRow(isPublicRow)

    let section2 = XLFormSectionDescriptor.formSection(withTitle: "File 1") as
    XLFormSectionDescriptor
    form.addFormSection(section2)

    let filenameRow = XLFormRowDescriptor(tag: "filename", rowType:
      XLFormRowDescriptorTypeText, title: "Filename")
    filenameRow.isRequired = true
    section2.addFormRow(filenameRow)

    let fileContent = XLFormRowDescriptor(tag: "fileContent", rowType:
      XLFormRowDescriptorTypeTextView, title: "File Content")
    fileContent.isRequired = true
    section2.addFormRow(fileContent)

    self.form = form
  }
}
