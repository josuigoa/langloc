#langloc
Macro based strictly typed localization manager for Haxe.

##Install
> haxelib install langloc

##Usage
The library uses CSV files to get the localizations. Those files are part of a structure like this:

* localization
    * eu_ES
        * strings.csv
            * test0,lehenengoa
            * test1,bigarrena
            * image,image_eu.jpg
            * test2,hirugarrena
    * en_UK
        * strings.csv
            * test0,first
            * test1,second
            * image,image_en.jpg
    * ...

The root folder (`localization`) path can be changed using `-D locales_path=new_path`. The `strings.csv` file format is `id,localized_text`.

First of all, we must define the library dependency in the `hxml` file
```javascript
-lib langloc
# -D locales_path=../locales
```

Next, import and initialize the manager
```haxe
import langloc.Loc;
...
Loc.init();
```
The localization `id`s are automatically created as static fields of the `langloc.Loc` class. So use them!
```haxe
Loc.set_language(Lang.eu_ES); //set language to Basque
trace( Loc.test1 ); //bigarrena
trace( Loc.test2 ); //hirugarrena

Loc.set_language(Lang.en_UK); //set language to English
trace( Loc.test1 ); //second
trace( Loc.test2 ); //localizable_3, it is not translated to en_UK
```

##Dynamic usage
Defining the `langloc_dynamic` flag, you will be able to load the localizations in a dynamic way like this:
```haxe
Loc.get_dynamic_localized('test1') //second
```

#How it works
The localization `id`s are created as `langloc.Loc` static inline fields. When compiling, those fields are translated to function calls to get the `localized_text` corresponding to that `id` thanks to [abstracts](https://haxe.org/manual/types-abstract.html). The language identifiers are created as `langloc.Lang` enum fields.

The macro parses the localization folder and creates the code below.

```haxe
class Loc {
...
    /* Code created by the macro
    static public var test0:LocalizableID = 0;
    static public var test1:LocalizableID = 1;
    static public var image:LocalizableID = 2;
    static public var test2:LocalizableID = 3;

    static public funtion init() {
        // the code below will not be created for completion (using #if !display statement)
        localizations = new Map();
        lang_map = langloc.Loc.localizations.get(Lang.en_UK);
        if (lang_map == null) lang_map = new Map();
        lang_map.set(test0, 'firts');
        lang_map.set(test1, 'second');
        lang_map.set(image, 'image_en.jpg');
        langloc.Loc.localizations.set(Lang.en_UK, lang_map);
        ...
    }
    */
...
}

@:build(langloc.Macros.build_langs())
enum Lang {
    /* Code created by the macro
    eu_ES;
    en_UK;
    ...
    */
}
```
In the end of the compilation, langloc will warn you if there is some missing translation. In the example above it should show that `test2` is not translated to `en_UK`

If you define the `print_localizable_ids` compilation flag, it will create a file called `localizable_ids` in the translations root directory. That file will store the LocalizableID and the name attached to it.

If you want a complete example, go to `test_project` folder
