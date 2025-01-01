import UIKit
import PhotosUI

class CreateEvents: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, PHPickerViewControllerDelegate {

    // MARK: - IBOutlets
   
    @IBOutlet weak var category: UIPickerView!
    
    @IBOutlet weak var governorate: UIPickerView!
    @IBOutlet weak var pickImageButton: UIButton!
    @IBOutlet weak var governorate2: UIPickerView!
    @IBOutlet weak var pickImage: UIImageView!
    // MARK: - Properties
    let categories = ["Art", "Sports", "Music", "Gaming"]
    let governorates = ["Muharraq", "Capital", "Northern", "Southern"]
    
    var selectedCategory: String?
    var selectedGovernorate: String?
    var selectedGovernorate2: String? // Added for governorate2
    var selectedImagePaths: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up UIPickerViews and Buttons
        setupPickers()
        setupPickImageButton()

        // Retrieve saved selections from UserDefaults
        retrieveSelections()
        
        // Restore previously selected values in the pickers
        restorePickerSelections()

        // Update the pickImage view with previously selected images
        updatePickImageViews()
    }

    // MARK: - Setup Methods
    private func setupPickers() {
        // Ensure UIPickerViews are properly initialized
        category.dataSource = self
        category.delegate = self
        
        governorate.dataSource = self
        governorate.delegate = self
        
        governorate2.dataSource = self // Same setup for governorate2
        governorate2.delegate = self
    }

    private func setupPickImageButton() {
        // Safely add the action to the pickImageButton
        pickImageButton.addTarget(self, action: #selector(openImagePicker), for: .touchUpInside)
    }

    // MARK: - Picker Data Source & Delegate Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == category {
            return categories.count
        } else {
            return governorates.count
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == category {
            return categories[row]
        } else {
            return governorates[row]
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == category {
            selectedCategory = categories[row]
        } else if pickerView == governorate {
            selectedGovernorate = governorates[row]
        } else if pickerView == governorate2 {
            selectedGovernorate2 = governorates[row] // Assign value for governorate2
        }
        saveSelections() // Save the selections to UserDefaults
    }

    // MARK: - UserDefaults Storage
    private func saveSelections() {
        UserDefaults.standard.set(selectedCategory, forKey: "selectedCategory")
        UserDefaults.standard.set(selectedGovernorate, forKey: "selectedGovernorate")
        UserDefaults.standard.set(selectedGovernorate2, forKey: "selectedGovernorate2") // Save governorate2 selection
        UserDefaults.standard.set(selectedImagePaths, forKey: "selectedImagePaths") // Save image paths
    }

    private func retrieveSelections() {
        selectedCategory = UserDefaults.standard.string(forKey: "selectedCategory")
        selectedGovernorate = UserDefaults.standard.string(forKey: "selectedGovernorate")
        selectedGovernorate2 = UserDefaults.standard.string(forKey: "selectedGovernorate2") // Retrieve governorate2
        selectedImagePaths = UserDefaults.standard.stringArray(forKey: "selectedImagePaths") ?? [] // Retrieve image paths
    }

    private func restorePickerSelections() {
        if let selectedCategory = selectedCategory, let categoryIndex = categories.firstIndex(of: selectedCategory) {
            category.selectRow(categoryIndex, inComponent: 0, animated: false)
        }

        if let selectedGovernorate = selectedGovernorate, let governorateIndex = governorates.firstIndex(of: selectedGovernorate) {
            governorate.selectRow(governorateIndex, inComponent: 0, animated: false)
        }

        if let selectedGovernorate2 = selectedGovernorate2, let governorate2Index = governorates.firstIndex(of: selectedGovernorate2) {
            governorate2.selectRow(governorate2Index, inComponent: 0, animated: false)
        }
    }

    // MARK: - Image Picker Methods
    @objc private func openImagePicker() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 5  // Limit to 5 images
        configuration.filter = .images   // Only allow images

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        selectedImagePaths.removeAll() // Clear previous selections

        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
                if let image = object as? UIImage {
                    if let data = image.jpegData(compressionQuality: 0.8) {
                        let fileManager = FileManager.default
                        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let filePath = documentDirectory.appendingPathComponent(UUID().uuidString + ".jpg")
                        do {
                            try data.write(to: filePath)
                            self?.selectedImagePaths.append(filePath.path)
                            DispatchQueue.main.async {
                                self?.updatePickImageViews() // Update image view
                            }
                        } catch {
                            print("Error saving image: \(error)")
                        }
                    }
                }
            }
        }

        picker.dismiss(animated: true, completion: nil)
    }

    func pickerDidCancel(_ picker: PHPickerViewController) {
        picker.dismiss(animated: true, completion: nil)
    }

    // MARK: - Update Image Views
    private func updatePickImageViews() {
        guard let pickImage = pickImage else { return }

        // Remove any previous image views
        pickImage.subviews.forEach { $0.removeFromSuperview() }

        var xPosition: CGFloat = 10 // Start position for the images

        // Loop through the stored image paths and display them
        for (index, path) in selectedImagePaths.enumerated() {
            if let image = UIImage(contentsOfFile: path) {
                let imageView = UIImageView(image: image)
                imageView.frame = CGRect(x: xPosition, y: 10, width: 60, height: 60)
                imageView.contentMode = .scaleAspectFill
                imageView.layer.cornerRadius = 8
                imageView.clipsToBounds = true

                pickImage.addSubview(imageView)

                imageView.alpha = 0
                UIView.animate(withDuration: 0.5, delay: 0.1 * Double(index), animations: {
                    imageView.alpha = 1
                })

                xPosition += 70 // Adjust space between images
            }
        }
    }
}
