# InfiniteSlider
 
A Light weight library for image slider with customizing features.  

### Swift Package Manager. 
Use following link to add package to your project and use latest version for stability.

https://github.com/StebinAlex/InfiniteSlider.git

### Sample Gif
![infiniteSlider](https://user-images.githubusercontent.com/72264665/110941438-63d4ff80-835e-11eb-8be9-035546d17623.gif)


## Usage 

Import `InfiniteSlider`

Use `InfiniteSlider` for Picker view.
```
let slider = InfiniteSlider(frame: CGRect(x: 0, y: 0, width: 300, height: 250))
slider.center = self.view.center 
slider.timeInterval = 4
slider.images = [UIImage(named: "1")!, UIImage(named: "2")!, UIImage(named: "3")!, UIImage(named: "4")!, UIImage(named: "5")!] 
slider.delegate = self
self.view.addSubview(slider)
```

use delegate `InfiniteSliderDelegate`
for getting the current index of image, also you click on image and get clicked image index value.

Also you can use image urls for displaying images. 

```
slider.imageUrls = ["url1","url2"]
```
For manually move image use below functions
```
slider.moveSliderLeft()
slider.moveSliderRight()
```

### Author

Stebin Alex. 

Please share, If you found this useful. 😊
