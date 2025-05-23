package;

import haxe.io.Bytes;
import haxe.io.Path;
import lime.utils.AssetBundle;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
import lime.utils.Assets;

#if sys
import sys.FileSystem;
#end

#if disable_preloader_assets
@:dox(hide) class ManifestResources {
	public static var preloadLibraries:Array<Dynamic>;
	public static var preloadLibraryNames:Array<String>;
	public static var rootPath:String;

	public static function init (config:Dynamic):Void {
		preloadLibraries = new Array ();
		preloadLibraryNames = new Array ();
	}
}
#else
@:access(lime.utils.Assets)


@:keep @:dox(hide) class ManifestResources {


	public static var preloadLibraries:Array<AssetLibrary>;
	public static var preloadLibraryNames:Array<String>;
	public static var rootPath:String;


	public static function init (config:Dynamic):Void {

		preloadLibraries = new Array ();
		preloadLibraryNames = new Array ();

		rootPath = null;

		if (config != null && Reflect.hasField (config, "rootPath")) {

			rootPath = Reflect.field (config, "rootPath");

			if(!StringTools.endsWith (rootPath, "/")) {

				rootPath += "/";

			}

		}

		if (rootPath == null) {

			#if (ios || tvos || webassembly)
			rootPath = "assets/";
			#elseif android
			rootPath = "";
			#elseif (console || sys)
			rootPath = lime.system.System.applicationDirectory;
			#else
			rootPath = "./";
			#end

		}

		#if (openfl && !flash && !display)
		
		#end

		var data, manifest, library, bundle;

		data = '{"name":null,"assets":"aoy4:pathy33:assets%2Ftextures%2FLilitaOne.fnty4:sizei14059y4:typey4:TEXTy2:idR1goR0y33:assets%2Ftextures%2FLilitaOne.pngR2i44200R3y5:IMAGER5R6goR0y31:assets%2Ftextures%2Ftexture.pngR2i459836R3R7R5R8goR0y31:assets%2Ftextures%2Ftexture.xmlR2i6045R3R4R5R9goR0y36:assets%2Fbackgrounds%2Froad_tile.pngR2i4600R3R7R5R10goR2i15936R3y5:MUSICR5y35:assets%2Fsounds%2Fbig_explosion.mp3y9:pathGroupaR12hgoR2i1252R3R11R5y34:assets%2Fsounds%2Fbutton_click.mp3R13aR14hgoR2i40959R3R11R5y30:assets%2Fsounds%2Fcar_loop.mp3R13aR15hgoR2i6144R3R11R5y33:assets%2Fsounds%2Fchange_lane.mp3R13aR16hgoR2i1217928R3R11R5y31:assets%2Fsounds%2Fgame_loop.mp3R13aR17hgoR2i9403R3R11R5y36:assets%2Fsounds%2Fnew_high_score.mp3R13aR18hgoR0y36:assets%2Flocalization%2Fstrings.jsonR2i1664R3R4R5R19goR0y37:assets%2Fparticles%2FbigExplosion.sdeR2i179325R3y6:BINARYR5R20goR0y36:assets%2Fparticles%2FblazingFire.sdeR2i58310R3R21R5R22goR0y30:assets%2Fparticles%2Fsmoke.sdeR2i58390R3R21R5R23goR0y36:assets%2Flayouts%2Flanguages_ui.jsonR2i9672R3R4R5R24y7:preloadtgoR0y43:assets%2Flayouts%2Fleaderboard_item_ui.jsonR2i3356R3R4R5R26R25tgoR0y38:assets%2Flayouts%2Fleaderboard_ui.jsonR2i7754R3R4R5R27R25tgoR0y32:assets%2Flayouts%2Flobby_ui.jsonR2i14806R3R4R5R28R25tgoR0y31:assets%2Flayouts%2Frace_ui.jsonR2i4379R3R4R5R29R25tgoR0y31:assets%2Flayouts%2Froad_ui.jsonR2i1682R3R4R5R30R25tgoR0y37:assets%2Flayouts%2Fround_over_ui.jsonR2i10633R3R4R5R31R25tgh","rootPath":null,"version":2,"libraryArgs":[],"libraryType":null}';
		manifest = AssetManifest.parse (data, rootPath);
		library = AssetLibrary.fromManifest (manifest);
		Assets.registerLibrary ("default", library);
		

		library = Assets.getLibrary ("default");
		if (library != null) preloadLibraries.push (library);
		else preloadLibraryNames.push ("default");
		

	}


}

#if !display
#if flash

@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_textures_lilitaone_fnt extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_textures_lilitaone_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_textures_texture_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_textures_texture_xml extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_backgrounds_road_tile_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_sounds_big_explosion_mp3 extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_sounds_button_click_mp3 extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_sounds_car_loop_mp3 extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_sounds_change_lane_mp3 extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_sounds_game_loop_mp3 extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_sounds_new_high_score_mp3 extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_localization_strings_json extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_particles_bigexplosion_sde extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_particles_blazingfire_sde extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_particles_smoke_sde extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_layouts_languages_ui_json extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_layouts_leaderboard_item_ui_json extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_layouts_leaderboard_ui_json extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_layouts_lobby_ui_json extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_layouts_race_ui_json extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_layouts_road_ui_json extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_layouts_round_over_ui_json extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__manifest_default_json extends null { }


#elseif (desktop || cpp)

@:keep @:file("Assets/layouts/languages_ui.json") @:noCompletion #if display private #end class __ASSET__assets_layouts_languages_ui_json extends haxe.io.Bytes {}
@:keep @:file("Assets/layouts/leaderboard_item_ui.json") @:noCompletion #if display private #end class __ASSET__assets_layouts_leaderboard_item_ui_json extends haxe.io.Bytes {}
@:keep @:file("Assets/layouts/leaderboard_ui.json") @:noCompletion #if display private #end class __ASSET__assets_layouts_leaderboard_ui_json extends haxe.io.Bytes {}
@:keep @:file("Assets/layouts/lobby_ui.json") @:noCompletion #if display private #end class __ASSET__assets_layouts_lobby_ui_json extends haxe.io.Bytes {}
@:keep @:file("Assets/layouts/race_ui.json") @:noCompletion #if display private #end class __ASSET__assets_layouts_race_ui_json extends haxe.io.Bytes {}
@:keep @:file("Assets/layouts/road_ui.json") @:noCompletion #if display private #end class __ASSET__assets_layouts_road_ui_json extends haxe.io.Bytes {}
@:keep @:file("Assets/layouts/round_over_ui.json") @:noCompletion #if display private #end class __ASSET__assets_layouts_round_over_ui_json extends haxe.io.Bytes {}
@:keep @:file("") @:noCompletion #if display private #end class __ASSET__manifest_default_json extends haxe.io.Bytes {}



#else



#end

#if (openfl && !flash)

#if html5

#else

#end

#end
#end

#end