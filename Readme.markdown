Swift Visual Format Language
===

This project is an attempt to bring the [Auto Layout Visual Format Language](https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/VisualFormatLanguage/VisualFormatLanguage.html) to Swift, without requiring strings or dictionaries. It uses some crazy operator overloading instead. Using it looks like this:

    view.addConstraints(horizontalConstraints( |-5.al-[redView.al]-0.al-[greenView.al]-0.al-[blueView.al]-5.al-|  ))

**This project is not finished. Nor is it necessarily a good idea. See the todo section and the drawbacks discussion.**

The purpose of the Visual Format Language is to make code that does layout _look_ like layout. Views are in brackets to look like rectangles `[view.al]`. Spaces between views are hyphens, like `[view.al]-5.al-[view2.al]`. A relationship to the container view is represented by a vertical bar, `|-0.al-[fullWidthView.al]-0.al-|`.

Notice the `.al` put on each view or constant. This returns an object that actually has the overloaded parameters, so I wouldn't be overloading the CGFloat `-` operator, for example.

More Examples
---

These examples contrast the visual format with the resulting constraints represented by the equation-based [SwiftAutoLayout package from indragiek](https://github.com/indragiek/SwiftAutoLayout). There are constraints that the visual format can't represent (such as aspect ratios), but the equations are much harder to skim.

    horizontalConstraints( [redView.al]-10.al-[greenView.al] )  
    greenView.al_leading == redView.al_trailing + 10

    verticalConstraints( |-5.al-[redView.al]-5.al-| )
    redView.al_top == redView.superview.al_top + 5
    redView.superview.al_bottom == redView.al_bottom + 5
    
    horizontalConstraints( [greenView.al == redView.al]-0.al-[blueView.al == greenView.al] )
    greenView.al_width == redView.al_width
    blueView.al_leading == greenView.al_trailing
    blueView.al_width == greenView.al_width
    
    // Impossible to represent in the visual format language
    greenView.al_width = 0.5 * greenView.al_height
  
Okay, so maybe the width constraints are easier to read in the equation format.

Drawbacks from the Objective-C / String API
---

The Objective-C API was string-based, meaning that the visual format language was in a string with the tokens in the string mapped to views or constants via a dictionary. Accessed from Swift, this looked like this:

    let views = ["redView" : redView, "greenView" : greenView, "blueView": blueView]
    self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-5-[redView]-0-[greenView.al]-0-[blueView.al]-5-|", options: nil, metrics: nil, views: views))

The string-based API has *much* better error messages. For example, when you type in the faulty format `|-0-[redView-0-|` you get the error

    Unable to parse constraint format: 
    Expected a ']' here. That is how you give the end of a view. 
    |-0-[redView-0-| 
                ^

That same faulty format in Swift gives you the unintelligble error

    Expected ',' separator


Because it was string-based, the language didn't have many constraints and could be designed better. For example, for width constraints `"[redView(>=greenView)][greenView]"` looks much better than `[redView.al >= greenView.al]-0.al-[greenView.al]`, but is not possible (as far as I can tell) with operator overloading.

The Objectice-C API is also able to do the "standard space" between controls. For example `"[button]-[textField]"` creates a constraint for whatever the correct space between a button and a textField should be. There is no other API for doing this.

Benefits over Objective-C / String API
---

There are some benefits to the Swift approach, mostly due to the fact that the compiler is involved in parsing the constraints intead of parsing a string at runtime.

If you have an invalid constraint format, it probably won't compile. You don't have to build and run to find that out. There are still some cases where I wasn't able to enforce every rule of the grammar through the type system and operator overloading and you will get a runtime crash instead, but I hope these are encountered rarely. The compiler errors aren't generally useful (see above), but at least they are early.

The biggest benefit is that you can use the view names directly without putting them into a string and a dictionary mapping them from names. The `NSDictionaryOfVariableBindings` macro isn't available in Swift, so it is a pain to declare a views dictionary. It basically meant that to make one constraint you  need to type the view's name three times, with two of those times being in a string not checked by the compiler. 

Another, smaller, benefit is that it is easier to use the same format for either Horizontal or Vertical layout. In the string-based API, I would append either `"H:"` or `"V:"` to the string. Now just use the `toConstraints(.Vertical, [redView.al]-0.al-[greenView.al] )` and change the axis parameter.

 
To Do
---
- Unit tests! This will be the next thing I work on.
- Inequalities like >= or <= aren't supported for spaces between views. It should support `|->=5-[redView.al]-<=10-[greenView.al]-==0-|`
- Priorities aren't supported. I am planning to use the ! operator, if it can be infix. For example, to make a high priority constraint it should look like `[redView.al]-10.al!750.al-[greenView.al]`
- Experiment with not requiring the `.al`. It is nice to not overload the common types, but it does decrease readability.

