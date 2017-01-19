package langloc;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;

class Macros {
    
    #if !display
    // This map will be use in the end of the compilation to check and warn if some translation is missing
    // Map<localizable_id, Array<language_id>>
    static var checker:Map<String, Array<String>>;
    #end
    static var languages:Array<String>;

    static public function build_langs() {
        
        var fields = Context.getBuildFields();
        // var locales_path = Sys.getCwd()+locales_dir;
        var locales_path = resolve_path();
        
        if (!sys.FileSystem.isDirectory(locales_path))
            Context.error('$locales_path has to be a directory.', Context.currentPos());
        
        for( l_name in sys.FileSystem.readDirectory(locales_path) ) {
            if (!sys.FileSystem.isDirectory(locales_path+l_name) || !sys.FileSystem.exists(locales_path+l_name+'/strings.csv')) continue;
            
            // create a field for every language directory
            fields.push({
                        name : l_name,
                        access : [],
                        kind : FVar(null, null),
                        doc : '${l_name} language code',
                        pos : Context.currentPos()
                    });
        }
        
        return fields;
    }

    static public function build_locales(locales_dir:String = 'localizations/') {
        
        var fields = Context.getBuildFields();
        // var locales_path = Sys.getCwd()+locales_dir;
        var locales_path = resolve_path();
        
        if (!sys.FileSystem.isDirectory(locales_path))
            Context.error('$locales_path has to be a directory.', Context.currentPos());
        
        var csv_lines, pair, loc_id, loc_text, expr, expr_ind;
        var line_break_ereg = ~/\r?\n/g;
        var id_text_sep_ereg = ~/,/;
        var localizable_ind;
        var created_fields = new Map<String, Int>();
        
        // array to store the expressions of the init() function
        var init_exprs = [];
        #if !display
        // Map<localizable_id, Array<languages>>
        checker = new Map<String, Array<String>>();
        var lang_array = [];
        Context.onAfterGenerate(on_after_generate);
        
        init_exprs.push(macro langloc.Loc.localizations = new Map());
        init_exprs.push(macro var lang_map);
        #end
        languages = [];
        
        for( l_name in sys.FileSystem.readDirectory(locales_path) ) {
            if (!sys.FileSystem.isDirectory(locales_path+l_name) || !sys.FileSystem.exists(locales_path+l_name+'/strings.csv')) continue;
            
            languages.push(l_name);
            
            localizable_ind = 0;
            #if !display
            // get the Map of the translations for the l_name language in the init() function
            init_exprs.push(macro {
                                lang_map = langloc.Loc.localizations.get(Lang.$l_name);
                                if (lang_map == null) lang_map = new Map();
                            });
            #end
            
            // read the strings.csv file and split the lines
            csv_lines = line_break_ereg.split(sys.io.File.getContent(locales_path+l_name+'/strings.csv'));
            for (l in csv_lines) {
                // every line has "id,translation" format
                pair = id_text_sep_ereg.split(l);
                loc_id = pair[0];
                loc_text = pair[1];
                // without this if, we would repeat the variable name for every language
                if (!created_fields.exists(loc_id)) {
                    // create the field, example: Loc.test:LocalizableID = 0;
                    expr = {
                                name : loc_id,
                                access : [Access.APublic, Access.AStatic, Access.AInline],
                                kind : FVar(macro :langloc.Loc.LocalizableID, macro $v{localizable_ind}),
                                doc : '${l_name}: ${loc_text}',
                                pos : Context.currentPos()
                            };
                    created_fields.set(loc_id, fields.push(expr)-1);
                } else {
                    // if there was an existing field for this localizable_id
                    // add the current translation to the documentation of that field
                    expr_ind = created_fields.get(loc_id);
                    expr = fields[expr_ind];
                    expr.doc += '\n${l_name}: ${loc_text}';
                    fields[expr_ind] = expr;
                }
                #if !display
                lang_array = checker.get(loc_id);
                if (lang_array == null) lang_array = [];
                lang_array.push(l_name);
                checker.set(loc_id, lang_array);
                // add the translation in the init() function
                init_exprs.push(macro lang_map.set($v{localizable_ind}, $v{loc_text}));
                #end
                
                
                localizable_ind++;
            }
            #if !display
            init_exprs.push(macro langloc.Loc.localizations.set(Lang.$l_name, lang_map));
            #end
        }
        
        // create the init() function
        fields.push({
                name:'init', pos:Context.currentPos(), access:[Access.APublic, Access.AStatic],
                kind:FieldType.FFun({
                        ret:null, args:[], 
                        expr:{expr:EBlock(init_exprs), pos:Context.currentPos()}
                    })
                });
        
        #if (!display && print_localizable_ids)
        var out = 'id\t-> name\n';
        out += '------------\n';
        for (f in fields) {
            switch f.kind {
                case FVar(macro :langloc.Loc.LocalizableID, val):
                    out += ExprTools.getValue(val) + '\t-> ${f.name}\n';
                case _:
            }
            
        }
        sys.io.File.saveContent(resolve_path()+'localizable_ids', out);
        #end
        
        return fields;
    }
    
    public static function resolve_path() {
		var resolve = true;
		var dir = Context.definedValue("locales_path");
		if( dir == null ) dir = "localizations/" else resolve = false;
		var pos = Context.currentPos();
		if( resolve )
			dir = try Context.resolvePath(dir) catch( e : Dynamic ) { Context.warning("Localizations directory not found in classpath '" + dir + "' (use -D locales_path=DIR)", pos); return "__invalid"; }
		var path = sys.FileSystem.fullPath(dir);
		if( !sys.FileSystem.exists(path) || !sys.FileSystem.isDirectory(path) )
			Context.warning("Localizations directory does not exists '" + path + "'", pos);
		return path+'/';
    }
    
    #if !display
    static function on_after_generate() {
        var c:Array<String>;
        for( c_key in checker.keys() ) {
            c = checker.get(c_key);
            if (c.length == languages.length) continue;
            for (l in languages) {
                if (c.indexOf(l) == -1) {
                    Context.warning( '"${c_key}" text has no translation to language "${l}"', Context.currentPos() );
                }
            }
        }
    }
    #end
}
