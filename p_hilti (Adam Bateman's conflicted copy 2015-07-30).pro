%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - RULES FOR "HILTI" PROCESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( hilti_rules, `9 Feb 2015` ).

i_rules_file( `p_hilti_duplicate.pro` ).
i_rules_file( `hilti sales office.pro` ).
i_rules_file( `hilti item enquire.pro` ).

i_user_field( invoice, additional_email_text, `Additional Email Text` ).

%=======================================================================
i_initialise_rule(  [  set( test_flag ), trace([`Set test flag`]) ]) :- i_mail(to,`orders.test@adaptris.net`).
%=======================================================================
i_initialise_rule(  [  set( test_flag ), trace([`Set test flag`]) ]) :- i_mail(to,`orders.test@ecx.adaptris.com`).
%=======================================================================

%=======================================================================
i_line_rule_cut( footer_line, [ 
%=======================================================================

	  q10(`sources`), `valid`, `on`

	, q0n(anything)

	, tab, narrative(s1), newline
	  
	, check(narrative(page) = 1)
	
	, trace([`Form Name`, narrative])

] ).

%=======================================================================
i_final_rule( [
%=======================================================================

	q10( [ without( buyer_party ), buyer_party( `LS` ) ] )
	
	, q10( [ without( supplier_party ), supplier_party( `LS` ) ] )
	
] ).

%=======================================================================
i_final_rule( [
%=======================================================================

	without( delivery_note_number ), without( delivery_note_reference )
	
	, without( delivery_party ), without( delivery_location )
	
	, without( delivery_city ), without( delivery_postcode )
	
	, force_result( `defect` )
	
	, force_sub_result( `missing_we` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		CIG CUP TIDYING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_op_param( xml_transform( delivery_address_line, In ), _, _, _, Out )
:-
	result( _, invoice, agent_code_3, `7500` ),
	trace( [ `CIG CUP Manipulation In`, In ] ),
	string_to_upper( In, InU ),
	
	( q_sys_sub_string( InU, 1, 8, `CIG: CUP` )
		->	q_sys_sub_string( In, 6, _, CIGValid )
		
		; 	In = CIGValid
	),
	!,
	
	( sys_string_trim( CIGValid, CIGValidTrim ),
		sys_string_length( CIGValid, CIGValidLen ),
		trace( [ `Length of String`, CIGValidLen ] ),
		sys_calculate( CUPLocation, CIGValidLen - 3 ),
		( CUPLocation = 1
			->	Out = ``
			
			;	sys_calculate( SpacePosition, CIGValidLen - 4 ),
			trace( [ `Positions`, CUPLocation, SpacePosition ] ),
			q_sys_sub_string( CIGValid, CUPLocation, 4, CUPTest ),
			trace( [ `CUPTest`, CUPTest ] ),
			q_sys_sub_string( CIGValid, CUPLocation, 4, `CUP:` ),
			sys_calculate( CIGEndPosition, SpacePosition - 1 ),
			q_sys_sub_string( CIGValid, 1, CIGEndPosition, Out ),
			trace( [ `Final String`, CIGValid ] )
		)
		
		;	CIGValid = Out
	),
	!,
	trace( [ `CIG Cup Manipulation Out`, Out ] )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		Capitalisation of Swedish Variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_analyse_invoice_fields_first
%-----------------------------------------------------------------------
:- result( _, invoice, agent_code_3, `2600` ), i_capitalise_things.
%=======================================================================
i_capitalise_things
%-----------------------------------------------------------------------
:-
	things_to_capitalise( ThingsToCapitalise ),	
	capitalise_variables( ThingsToCapitalise )
.
%=======================================================================
capitalise_variables( [ ] ).
%=======================================================================
capitalise_variables( [ H | T ] )
%-----------------------------------------------------------------------
:-
	( result( _, invoice, H, ValueIn ),
		string_to_upper( ValueIn, ValueOut ),
		sys_retractall( result( _, invoice, H, ValueIn ) ),
		assertz_derived_data( invoice, H, ValueOut, i_capitalise_things )
		
		;	not( result( _, invoice, H, _ ) )
	),
	!,
	capitalise_variables( T )
.
%=======================================================================
things_to_capitalise( [ buyer_contact, delivery_contact ] ).
%=======================================================================

i_op_param( xml_transform( Var, In ), _, _, _, Out )
:-
	result( _, invoice, agent_code_3, `2600` ),
	q_sys_member( Var, [ delivery_party, delivery_dept, delivery_address_line, delivery_street, delivery_city, buyer_contact, delivery_contact ] ),
	string_to_upper( In, Out )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		Failure on missing item codes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%	- Currently in place for DE only
%
%=======================================================================
i_analyse_line_fields_first( LID )
%-----------------------------------------------------------------------
:- i_fail_orders_without_item_codes( LID ).
%=======================================================================

%=======================================================================
i_fail_orders_without_item_codes( LID )
%-----------------------------------------------------------------------
:- result( _, invoice, agent_code_3, Agent3 ), missing_item_mo( Agent3 ), not( grammar_set( failed_missing_item ) ),
%=======================================================================

	( result( _, LID, line_item, Item )
		->	string_to_lower( Item, ItemL ),
			ItemL = `missing`
			
		;	not( result( _, LID, line_item, _ ) )
	),
	
	sys_assertz( grammar_set( failed_missing_item ) ),
	
	assertz_derived_data( invoice, force_result, `failed`, i_fail_orders_without_item_codes ),
	assertz_derived_data( invoice, force_sub_result, `missing_item_rule`, i_fail_orders_without_item_codes ),
	!
.

missing_item_mo( `5000` ).
missing_item_mo( `0001` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		HILTI UOM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%======================================================
%		Manual Additions
%======================================================

hilti_uom(`PIECES`,`EA`).
hilti_uom(`CENT`,`EA`).

hilti_uom(`CUSTOMER UOM`,`UoM Hilti`).

hilti_uom( `10`, `EA` ).
hilti_uom( `100`, `EA` ).
hilti_uom( `1000`, `EA` ).
hilti_uom( `B03`, `EA` ).
hilti_uom( `B06`, `EA` ).
hilti_uom( `B10`, `EA` ).
hilti_uom( `B12`, `EA` ).
hilti_uom( `B1C`, `EA` ).
hilti_uom( `B20`, `EA` ).
hilti_uom( `B25`, `EA` ).
hilti_uom( `B2C`, `EA` ).
hilti_uom( `B40`, `EA` ).
hilti_uom( `B50`, `EA` ).
hilti_uom( `B80`, `EA` ).
hilti_uom( `BAG`, `PK` ).
hilti_uom( `BOITE`, `EA` ).
hilti_uom( `BOT`, `EA` ).
hilti_uom( `BOX`, `PK` ).
hilti_uom( `BOX`, `PK` ).
hilti_uom( `BOX`, `PK` ).
hilti_uom( `BOXES`, `PK` ).
hilti_uom( `BOXES`, `PK` ).
hilti_uom( `BOXES`, `PK` ).
hilti_uom( `BT`, `PK` ).
hilti_uom( `BT`, `PK` ).
hilti_uom( `BT`, `PK` ).
hilti_uom( `BX`, `PK` ).
hilti_uom( `BX`, `PK` ).
hilti_uom( `BX`, `PK` ).
hilti_uom( `C62`, `EA` ).
hilti_uom( `CENT`, `EA` ).
hilti_uom( `CF`, `EA` ).
hilti_uom( `CF`, `EA` ).
hilti_uom( `CF`, `EA` ).
hilti_uom( `CF`, `PK` ).
hilti_uom( `CF`, `PK` ).
hilti_uom( `CF`, `PK` ).
hilti_uom( `CON`, `PK` ).
hilti_uom( `CON`, `PK` ).
hilti_uom( `CON`, `PK` ).
hilti_uom( `CT`, `EA` ).
hilti_uom( `CT`, `EA` ).
hilti_uom( `CT`, `EA` ).
hilti_uom( `DU`, `EA` ).
hilti_uom( `EA`, `EA` ).
hilti_uom( `EA`, `EA` ).
hilti_uom( `EA`, `EA` ).
hilti_uom( `EACH`, `EA` ).
hilti_uom( `EACH`, `EA` ).
hilti_uom( `EACH`, `EA` ).
hilti_uom( `IT`, `EA` ).
hilti_uom( `IT`, `EA` ).
hilti_uom( `JE`, `EA` ).
hilti_uom( `JE`, `EA` ).
hilti_uom( `JE`, `EA` ).
hilti_uom( `KAS`, `EA` ).
hilti_uom( `KAS`, `EA` ).
hilti_uom( `KPL`, `EA` ).
hilti_uom( `KPL`, `EA` ).
hilti_uom( `KPL`, `EA` ).
hilti_uom( `LE`, `EA` ).
hilti_uom( `LE`, `EA` ).
hilti_uom( `LE`, `EA` ).
hilti_uom( `LIN`, `M` ).
hilti_uom( `LIN.M`, `M` ).
hilti_uom( `LM`, `M` ).
hilti_uom( `LOT`, `EA` ).
hilti_uom( `LOT`, `EA` ).
hilti_uom( `LOT`, `EA` ).
hilti_uom( `LT`, `EA` ).
hilti_uom( `LT`, `EA` ).
hilti_uom( `LT`, `EA` ).
hilti_uom( `M`, `M` ).
hilti_uom( `M`, `M` ).
hilti_uom( `M2`, `EA` ).
hilti_uom( `METER`, `M` ).
hilti_uom( `METR`, `M` ).
hilti_uom( `METRE`, `M` ).
hilti_uom( `MÈTRE`, `M` ).
hilti_uom( `MÈTRE`, `M` ).
hilti_uom( `METRES`, `M` ).
hilti_uom( `METRES`, `M` ).
hilti_uom( `METRES`, `M` ).
hilti_uom( `MÈTRES`, `M` ).
hilti_uom( `MÈTRES`, `M` ).
hilti_uom( `ML`, `M` ).
hilti_uom( `ML`, `M` ).
hilti_uom( `ML`, `M` ).
hilti_uom( `ML.`, `M` ).
hilti_uom( `MT`, `M` ).
hilti_uom( `MT`, `M` ).
hilti_uom( `MT`, `M` ).
hilti_uom( `MTR`, `M` ).
hilti_uom( `MTR`, `M` ).
hilti_uom( `MTR`, `M` ).
hilti_uom( `N`, `EA` ).
hilti_uom( `N`, `EA` ).
hilti_uom( `NO`, `EA` ).
hilti_uom( `NO`, `EA` ).
hilti_uom( `NO`, `EA` ).
hilti_uom( `NO`, `EA` ).
hilti_uom( `NO.`, `EA` ).
hilti_uom( `NO.`, `EA` ).
hilti_uom( `NR`, `EA` ).
hilti_uom( `NR`, `EA` ).
hilti_uom( `NR`, `EA` ).
hilti_uom( `NR.`, `EA` ).
hilti_uom( `P`, `EA` ).
hilti_uom( `P`, `EA` ).
hilti_uom( `PAC`, `PK` ).
hilti_uom( `PAC`, `PK` ).
hilti_uom( `PAC`, `PK` ).
hilti_uom( `PACK`, `PK` ).
hilti_uom( `PACK`, `PK` ).
hilti_uom( `PACK`, `PK` ).
hilti_uom( `PACKET`, `PK` ).
hilti_uom( `PACKET`, `PK` ).
hilti_uom( `PACKS`, `PK` ).
hilti_uom( `PACKS`, `PK` ).
hilti_uom( `PACKS`, `PK` ).
hilti_uom( `PACZKA`, `PK` ).
hilti_uom( `PAKET`, `EA` ).
hilti_uom( `PAQ`, `PK` ).
hilti_uom( `PAQ`, `PK` ).
hilti_uom( `PAQ`, `PK` ).
hilti_uom( `PC`, `EA` ).
hilti_uom( `PC`, `EA` ).
hilti_uom( `PC`, `EA` ).
hilti_uom( `PCE`, `EA` ).
hilti_uom( `PCE`, `EA` ).
hilti_uom( `PCE`, `EA` ).
hilti_uom( `PCK`, `PK` ).
hilti_uom( `PCS`, `EA` ).
hilti_uom( `PCS`, `EA` ).
hilti_uom( `PCS`, `EA` ).
hilti_uom( `PG`, `EA` ).
hilti_uom( `PIE`, `EA` ).
hilti_uom( `PIECE`, `EA` ).
hilti_uom( `PIECE`, `EA` ).
hilti_uom( `PIECE`, `EA` ).
hilti_uom( `PKG`, `PK` ).
hilti_uom( `PKG`, `PK` ).
hilti_uom( `PKG`, `PK` ).
hilti_uom( `PKT`, `PK` ).
hilti_uom( `PKT`, `PK` ).
hilti_uom( `PKT`, `PK` ).
hilti_uom( `PP`, `EA` ).
hilti_uom( `PZ`, `EA` ).
hilti_uom( `PZ`, `EA` ).
hilti_uom( `PZ`, `EA` ).
hilti_uom( `PZ.`, `EA` ).
hilti_uom( `PZ.`, `EA` ).
hilti_uom( `PZ.`, `EA` ).
hilti_uom( `PZI`, `EA` ).
hilti_uom( `ROLLE`, `EA` ).
hilti_uom( `SET`, `EA` ).
hilti_uom( `ST`, `EA` ).
hilti_uom( `ST`, `EA` ).
hilti_uom( `ST`, `EA` ).
hilti_uom( `ST.`, `EA` ).
hilti_uom( `STC`, `EA` ).
hilti_uom( `STCK`, `EA` ).
hilti_uom( `STCK`, `EA` ).
hilti_uom( `STK`, `EA` ).
hilti_uom( `STK`, `EA` ).
hilti_uom( `STK`, `EA` ).
hilti_uom( `STÜCK`, `EA` ).
hilti_uom( `STUK`, `EA` ).
hilti_uom( `STUK`, `EA` ).
hilti_uom( `STUK`, `EA` ).
hilti_uom( `STYK`, `EA` ).
hilti_uom( `SZTUKA`, `EA` ).
hilti_uom( `U`, `EA` ).
hilti_uom( `UD`, `EA` ).
hilti_uom( `UD`, `EA` ).
hilti_uom( `UD`, `EA` ).
hilti_uom( `UN`, `EA` ).
hilti_uom( `UN`, `EA` ).
hilti_uom( `UN`, `EA` ).
hilti_uom( `UND`, `EA` ).
hilti_uom( `UND`, `EA` ).
hilti_uom( `UND`, `EA` ).
hilti_uom( `UNIT`, `EA` ).
hilti_uom( `UNITE`, `EA` ).
hilti_uom( `UNITÉ`, `EA` ).
hilti_uom( `UNITÉ`, `EA` ).
hilti_uom( `UNT`, `EA` ).
hilti_uom( `UT`, `EA` ).
hilti_uom( `UT`, `EA` ).
hilti_uom( `UT`, `EA` ).
hilti_uom( `VE`, `EA` ).
hilti_uom( `VE`, `EA` ).
hilti_uom( `VE`, `EA` ).
hilti_uom( `KIT`, `PAK` ).
hilti_uom( `PAI`, `PAK` ).
hilti_uom( `SA`, `PAK` ).
hilti_uom( `STV`, `EA` ).