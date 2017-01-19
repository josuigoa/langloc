package langloc;

@:build(langloc.Macros.build_locales())
class Loc {
    
    // Map<language_code, Map<localizable_id, localized_text>>
    static var localizations:Map<Lang, Map<LocalizableID, String>>;
    static var current_language:Lang;
    
    static public function set_language(_new_lang:Lang) current_language = _new_lang;
    
    @:noCompletion static public function get_localized_text(l:LocalizableID) : String {
        var localized_text = '';
        if (Loc.localizations != null) {
            var lang_map = Loc.localizations.get(Loc.current_language);
            if (lang_map != null) {
                localized_text = lang_map.get(l);
                if (localized_text == null) {
                    trace( 'Not found the translation for LocalizableID($l) in language "$current_language".' );
                    localized_text = 'localizable_' + Std.string(l);
                }
            } else {
                trace( 'Language "${Loc.current_language}" not found.' );
            }
        } else {
            localized_text = 'localizable_' + Std.string(l);
            trace( 'Loc.localizations is null, do you call to Loc.init() function?' );
        }
        return localized_text;
    }
    
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
    
}

@:build(langloc.Macros.build_langs())
enum Lang {
    /* Code created by the macro
    eu_ES;
    en_UK;
    es_ES;
    */
}

abstract LocalizableID(Int) from Int to Int {

    public inline function new( v : Int ) this = v;
    
    @:to public inline function toString() {
        return Loc.get_localized_text(this);
    }
}