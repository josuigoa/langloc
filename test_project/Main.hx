
import langloc.Loc;

class Main {
    
    public function new() {
        
        Loc.init();
        
        // Loc.set_language('eu'); // error: String should be langloc.Lang
        
        trace( Loc.test1 ); //localizable_1
        
        Loc.set_language(Lang.eu_ES);
        trace( 'strict: ' + Loc.test1 ); //bigarrena
        trace( 'dynamic: ' + Loc.get_dynamic_localized('test1') ); //bigarrena
        
        Loc.set_language(Lang.en_UK);
        trace( 'strict: ' + Loc.test1 ); //second
        trace( 'dynamic: ' + Loc.get_dynamic_localized('test1') ); //second
        
        Loc.set_language(Lang.es_ES);
        trace( 'strict: ' + Loc.test1 ); //segundo
        trace( 'dynamic: ' + Loc.get_dynamic_localized('test1') ); //segundo
    }
    
    static function main() {
        new Main();
    }
}