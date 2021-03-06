%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - DOWNER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( downer, `09 June 2015` ).

i_date_format( _ ).

i_format_postcode( X, X ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).

i_op_param( orders05_idocs_first_and_last_name( Var, Name1, Name2 ), _, _, _, _ )
:-
	trace( [ `Var`, Var ] ),
	q_sys_member( Var, [ buyer_contact, delivery_contact ] ),
	result( _, invoice, Var, Res ),
	trace( [ `Result`, Res ] ),
	sys_string_split( Res, ` `, [ Name1 | SurnameList ] ),
	wordcat( SurnameList, Name2 ),
	trace( [ `Names`, Name1, Name2 ] )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	  
%	, get_suppliers_code_for_buyer % Requested to be removed 21/04/2015

	, get_order_number
	
	, get_order_date
	
	, get_buyer_contact
	, get_buyer_ddi
	, get_buyer_email
	, get_buyer_fax
	
	, get_delivery_note_number
	
	, get_shipping_instructions
	
	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

	, get_totals

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STATIC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [ 
%=======================================================================

	  buyer_party( `LS` )

	, supplier_party( `LS` )

	, buyer_registration_number( `AU-ADAPTRI` )

	, or( [ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	] )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`2500`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, sender_name( `Downer EDI Engineering Power Pty Ltd.` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,10,line), generic_horizontal_details( [ [ `Order`, `No`, `:` ], order_number, s1 ] ) 
	
] ).

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ [ `Order`, `Date`, `:` ], invoice_date, date ] )
	  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SCFB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_suppliers_code_for_buyer, [ 
%=======================================================================

	  q(0,7,line), generic_horizontal_details( [ scfb_end, [ begin, q(dec,4,5), end ], check( scfb_end(start) > 300 ) ] )
	
	, check( scfb_end = End )
	, check( strcat_list( [ `AUDOWNER`, End ], SCFB ) )
	, suppliers_code_for_buyer( SCFB )
	, trace( [ `Suppliers code for Buyer`, SCFB ] )
	
	, q(0,4,line), generic_horizontal_details( [ [ `Delivery`, `Address` ] ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACT INFORMATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  qn0(line), generic_horizontal_details( [ [ `Requested`, `by`,`:` ], buyer_contact, s1 ] )
	  
	, check( buyer_contact = Con )
	, delivery_contact( Con )
	
] ).

%=======================================================================
i_rule( get_buyer_email, [ 
%=======================================================================

	  qn0(line), generic_horizontal_details( [ [ `Email`,`:` ], buyer_email, s1 ] )
	  
	, check( buyer_email = Email )
	, delivery_email( Email )
	
] ).

%=======================================================================
i_rule( get_buyer_ddi, [ 
%=======================================================================

	  qn0(line), generic_horizontal_details( [ [ or( [ `Querries`, `Queries` ] ),`:`, `(`, `T`, `)` ], buyer_ddi, sf, `(` ] )
	  
	, check( buyer_ddi = DDI )
	, delivery_ddi( DDI )
	
] ).

%=======================================================================
i_rule( get_buyer_fax, [ 
%=======================================================================

	  qn0(line), generic_horizontal_details( [ [ or( [ `Querries`, `Queries` ] ),`:`, q0n(word), `(`, `f`, `)` ], buyer_fax, s1 ] )
	  
	, check( buyer_fax = Fax )
	, delivery_fax( Fax )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [ qn0(line), totals_line ] ).
%=======================================================================
i_line_rule( totals_line, [
%=======================================================================

	  q0n( [ dummy(s1), tab ] ), `Order`, `Value`, tab
	  
	, read_ahead( [ generic_item( [ total_net, d ] ) ] )	
	, generic_item( [ total_invoice, d ] )
	
	, or( [ [ with( invoice, delivery_charge, Charge )	
			, check( sys_calculate_str_subtract( total_net, Charge, Net_1 ) )			
			, net_subtotal_2( Charge )		
			, gross_subtotal_2( Charge )
			
		]
		
		, [ without( delivery_charge )	
			, check( total_net = Net_1 )		
		]
		
	] )
	
	, net_subtotal_1( Net_1 )	
	, gross_subtotal_1( Net_1 )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SHIPPING INSTRUCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_shipping_instructions, [ 
%=======================================================================

	  q(0,15,line), read_ahead( generic_horizontal_details( [ [ `Delivery`, `Address` ] ] ) )
	 
	, q(0,10,line)
	
	, generic_horizontal_details( [ 
		[ nearest( generic_hook(start), 10, 10 )
			, read_ahead( or( [ [ `Att`, `:` ], [ `Special`, `Instructions` ] ] ) )
		]
		, shipping_instructions, sf, or( [ dum(f([begin, q(dec,4,5), end ])), gen_eof ] )
	] )
	
	, q0n( 
		or( [ generic_line( [ [ nearest( generic_hook(start), 10, 10 ), append( shipping_instructions(s1), `~`, `` ) ] ] )
			, line
		] )
	)
	
	, line_header_line

] ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY NOTE NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_note_number, [ 
%=======================================================================

	  q(0,30,line), read_ahead( generic_horizontal_details( [ [ `Delivery`, `Address` ] ] ) )
	 
	, gen1_parse_text_rule( [ -150, 150, line_header_line ] )
	, trace( [ `Captured`, captured_text ] )
	
	, check( i_user_check( perform_address_lookup, captured_text, DNN, SCFB ) )
	
	, delivery_note_number( DNN )
	, trace( [ `Delivery Note Number`, DNN ] )
	
	, or( [ check( SCFB = `` )
	
		, [ remove( suppliers_code_for_buyer )
			, suppliers_code_for_buyer( SCFB )
			, trace( [ `SCFB`, SCFB ] )
		]
	] )

] ).

%=======================================================================
i_user_check( perform_address_lookup, TextIn, DNN, SCFB )
%=======================================================================
:-
	string_to_upper( TextIn, TextInU ),
	
	Pred = address_lookup,
	
	Call =.. [ Pred, State, Street, PC, DNN, SCFB ],
	
	Call,
	trace( [ `Trying`, DNN ] ),
	( DNN = `Missing`
		->	true
		
		;	q_sys_sub_string( TextInU, _, _, PC ),
			q_sys_sub_string( TextInU, _, _, State ),
			q_sys_sub_string( TextInU, _, _, Street )
	)
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line
	 
	, trace( [ `found header` ] )

	, q0n( [

		or( [  line_invoice_line
		
			, line_continuation_line 
			
			, line

		] )

	] ), line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Item`, tab, or( [ [ `WBS`, `Code` ], `Commodity` ] ), tab, header ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or( [ [ `Requested`, `By` ]
	
		, [ dummy, check( dummy(page) \= header(page) ) ]
		
	] )
	
] ).


%=======================================================================
i_line_rule_cut( line_continuation_line, [ test( allow_cont ), append( line_descr(s1), ` `, `` ), newline ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================
   
	  generic_item( [ line_order_line_number, d, tab ] )
	  
	, generic_item( [ line_item_for_buyer, s1, tab ] )
	  
	, or( [ [ q10( word ), generic_item( [ line_item, [ begin, q(dec,4,10), end ], q10( `-` ) ] ) ]
	
		, line_item( `Missing` )
		
	] )

	, generic_item_cut( [ line_descr, s1, tab ] )

	, generic_item_cut( [ line_quantity, d, tab ] )

	, generic_item( [ line_quantity_uom_code, s1, tab ] )

	, generic_item( [ line_unit_amount, d, tab ] )
	
	, generic_item( [ price_uom, s1, tab ] )

	, generic_item( [ disc, d, tab ] )
	
	, generic_item( [ line_net_amount, d, tab ] )
	
	, generic_item( [ some_date, date, newline ] )

	, q10( [ check( i_user_check( check_for_delivery, line_descr ) )

		, line_type( `ignore` )
		
		, check( line_net_amount = Net )

		, delivery_charge( Net )
	
	] )
	
	, set( allow_cont )
	
] ).

%=======================================================================
i_user_check( check_for_delivery, Delivery ):-
%=======================================================================

	  string_to_lower( Delivery, Delivery_L )
	, sys_string_split( Delivery_L, ` `, Delivery_Words )
	, q_sys_member( Delivery_Word, Delivery_Words )
	, q_sys_member( Delivery_Word, [ `delivery`, `deliver`, `freight`, `carriage`, `haulage` ] )
	, trace( `delivery line, line being ignored` )
.

address_lookup( `WINNELLIE`, `CNR LEE ST & STEWART HWY`, `820`, `19999040`, `11126645` ).
address_lookup( `WINNELLIE`, `52 COONAWARRA RD`, `820`, `20099720`, `11126645` ).
address_lookup( `ALYANGULA`, `YARRADELIA RD`, `885`, `20702474`, `11126645` ).
address_lookup( `SYDNEY`, `BENNELONG POINT`, `2000`, `21441092`, `11126640` ).
address_lookup( `SYDNEY`, `MACQUARIE ST`, `2000`, `20400802`, `11126640` ).
address_lookup( `DARLINGTON`, `CNR ABERCROMBIE & CODRINGTON STS`, `2008`, `20974712`, `11126640` ).
address_lookup( `MASCOT`, `GATE 38 COWARD ST`, `2020`, `20687028`, `11126640` ).
address_lookup( `KENSINGTON`, `HIGH STREET`, `2033`, `18692189`, `11126640` ).
address_lookup( `PORT BOTANY`, `FORESHORE ROAD`, `2036`, `20674457`, `11126640` ).
address_lookup( `CAMPERDOWN`, `PHYSICS RD - OFF CITY RD`, `2050`, `21404590`, `11126640` ).
address_lookup( `GLADESVILLE`, `480 VICTORIA RD`, `2111`, `11126640`, `11126640` ).
address_lookup( `GLADESVILLE`, `22-24 COLLEGE ST`, `2111`, `20370591`, `11126640` ).
address_lookup( `LIDCOMBE`, `35 PARRAMATTA RD`, `2141`, `22007673`, `11126640` ).
address_lookup( `AUBURN`, `85 ST HILLIERS ROAD`, `2144`, `21517301`, `11126640` ).
address_lookup( `BELLA VISTA`, `4 CELEBRATION DR`, `2153`, `21517319`, `11126640` ).
address_lookup( `LIVERPOOL`, `LOADING DOCK 5 BATHURST STREET`, `2170`, `21873371`, `11126640` ).
address_lookup( `HOLSWORTHY`, `MOOREBANK AVE`, `2173`, `21286935`, `11126640` ).
address_lookup( `MIRANDA`, `L4 ROOF ENTRY OFF WANDELLA RD`, `2228`, `22107669`, `11126640` ).
address_lookup( `GOSFORD`, `CNR SHOWGROUND RD&GLENNING ST WEST`, `2250`, `21233052`, `11126645` ).
address_lookup( `ARGENTON`, `OFF MARGARET ST`, `2284`, `19448267`, `11126645` ).
address_lookup( `CHARLESTOWN`, `PEARSON ST`, `2290`, `17277049`, `11126645` ).
address_lookup( `Carrington`, `OFF BOURKE ST`, `2294`, `20830054`, `11126645` ).
address_lookup( `KOORAGANG ISLAND`, `CNR EGRET AND RAVEN ST`, `2304`, `17213175`, `11126645` ).
address_lookup( `HEXHAM`, `CALLEGHAN ST`, `2322`, `11126645`, `11126645` ).
address_lookup( `TOMAGO`, `OLD PUNT RD`, `2322`, `19597411`, `11126645` ).
address_lookup( `RAVENSWORTH`, `LEMINGTON RD`, `2330`, `20182995`, `11126645` ).
address_lookup( `RAVENSWORTH`, `PIKES GULLY RD`, `2330`, `19611229`, `11126640` ).
address_lookup( `MOUNT THORLEY`, `PUTTY RD`, `2330`, `20155165`, `11126645` ).
address_lookup( `SINGLETON`, `ARMY CAMP RD`, `2330`, `19369470`, `11126645` ).
address_lookup( `MOUNT THORLEY`, `21 WOODLAND RD`, `2330`, `18727881`, `11126645` ).
address_lookup( `RAVENSWORTH`, `LIDDELL STATION RD`, `2330`, `19125849`, `11126645` ).
address_lookup( `MUSWELLBROOK`, `THOMAS MITCHELL DR- MT ARTHUR MINE`, `2333`, `21902277`, `11126645` ).
address_lookup( `MAULES CREEK`, `MAULES CREEK`, `2382`, `21666780`, `11126645` ).
address_lookup( `BALLINA`, `FISHERY CREEK RD`, `2478`, `19854146`, `11126645` ).
address_lookup( `UNANDERRA`, `10 ORANGE GROVE AVE`, `2526`, `18404356`, `11126640` ).
address_lookup( `COOMA`, `82 POLO FLAT RD`, `2630`, `21585421`, `11126645` ).
address_lookup( `PENRITH`, `585 HIGH ST`, `2750`, `21765249`, `11126640` ).
address_lookup( `ULAN`, `ULAN WEST CONSTRUCTION PROJECT`, `2850`, `21111592`, `11126645` ).
address_lookup( `GARBUTT`, `49 - 53 DALRYMPLE ROAD`, `4814`, `20169473`, `11126645` ).
address_lookup( `MOUNT ISA`, `GEORGE FISHER MINE`, `4825`, `21812312`, `11126640` ).
address_lookup( `PERTH`, `WELLINGTON ST`, `6000`, `21479485`, `11126644` ).
address_lookup( `NORTHBRIDGE`, `GATE 10, ROE ST`, `6003`, `20521244`, `11126644` ).
address_lookup( `CRAIGIE`, `922 OCEAN REEF RD`, `6025`, `20651273`, `11126644` ).
address_lookup( `RIDGEWOOD`, `PAST THE END OF RATHKEALE BLVD`, `6030`, `21116195`, `11126644` ).
address_lookup( `ALKIMOS`, `ROMEO RD WEST`, `6038`, `18291814`, `11126644` ).
address_lookup( `CANNING VALE`, `9 MODAL CRES`, `6155`, `11126644`, `11126644` ).
address_lookup( `BIBRA LAKE`, `SHED1, DOOR2, LOT 15 SUDLOW RD`, `6163`, `22127298`, `11126644` ).
address_lookup( `KWINANA`, `HOGG ROAD`, `6167`, `20403430`, `11126644` ).
address_lookup( `KWINANA`, `1 BUTCHER ST`, `6167`, `19404590`, `11126644` ).
address_lookup( `KWINANA`, `OFF COCKBURN RD`, `6167`, `18766904`, `11126644` ).
address_lookup( `BALDIVIS`, `BALDIVIS SHOPPING CENTRE`, `6171`, `21782970`, `11126644` ).
address_lookup( `BINNINGUP`, `SSWA STAGE 2 PLANT`, `6233`, `20541321`, `11126644` ).
address_lookup( `BINNINGUP`, `LOT 32 TARANTO RD`, `6233`, `18397454`, `11126644` ).
address_lookup( `BODDINGTON`, `ATTENTION: DARREN 0408094233`, `6390`, `21561041`, `11126644` ).
address_lookup( `KOOLYANOBBING`, `KOOLYANOBBING MINE SITE`, `6427`, `19423425`, `11126644` ).
address_lookup( `KALGOORLIE`, `CNR HUNTER ST & GREAT EASTERN HWY`, `6430`, `20071447`, `11126644` ).
address_lookup( `MOUNT KEITH`, `BHP NMK MINE SITE`, `6437`, `18389162`, `11126644` ).
address_lookup( `ESPERANCE`, `ESPERANCE PORT SEA & LAND`, `6450`, `19546732`, `11126644` ).
address_lookup( `ONSLOW`, `VIA ONSLOW`, `6710`, `20403583`, `11126644` ).
address_lookup( `KARRATHA`, `COWLE RD`, `6714`, `19956097`, `11126644` ).
address_lookup( `KARRATHA`, `WOODSIDE ENERGY`, `6714`, `21723746`, `11126644` ).
address_lookup( `KARRATHA`, `W1252 SITE B CIVIL`, `6714`, `17585898`, `11126644` ).
address_lookup( `KARRATHA`, `PLUTO LNG PROJECT`, `6714`, `13916686`, `11126644` ).
address_lookup( `KARRATHA`, `BURRUP RD`, `6714`, `20163954`, `11126644` ).
address_lookup( `KARRATHA`, `CONTRACTOR LAYDOWN`, `6714`, `20031253`, `11126644` ).
address_lookup( `KARRATHA`, `LOT 3017, VILLAGE ROAD`, `6714`, `21504195`, `11126644` ).
address_lookup( `PORT HEDLAND`, `PHIHP PROJECT`, `6721`, `21039836`, `11126644` ).
address_lookup( `PORT HEDLAND`, `RGP 5 PROJECT`, `6721`, `17781004`, `11126644` ).
address_lookup( `PORT HEDLAND`, `SL1&2 PROJECT`, `6721`, `21383986`, `11126644` ).
address_lookup( `WEDGEFIELD`, `13 MUNDA WAY`, `6721`, `19033026`, `11126644` ).
address_lookup( `SOUTH HEDLAND`, `C/O MOOKA CAMP EPCM OFFICE`, `6722`, `21374442`, `11126644` ).
address_lookup( `NEWMAN`, `TOLL IPEC DEPOT`, `6753`, `20254512`, `11126644` ).
address_lookup( `NEWMAN`, `BHP BRIDGE REPLACEMENT NML 291`, `6753`, `21902203`, `11126644` ).
address_lookup( `VIA NEWMAN`, `HOPE DOWNS 4 MINE SITE`, `6753`, `20419917`, `11126644` ).
address_lookup( `NEWMAN`, `ELECTRICAL WORKS 15040`, `6753`, `20471818`, `11126644` ).
address_lookup( `NEWMAN`, `30KM OUT OF NEWMAN`, `6753`, `20910311`, `11126644` ).
address_lookup( `NEWMAN`, `RGP 5 PROJECT`, `6753`, `18600564`, `11126644` ).
address_lookup( `NEWMAN`, `LOT 1898 LAVER ST`, `6753`, `20271102`, `11126644` ).
address_lookup( `NEWMAN`, `VIA WHALEBACK GATEHOUSE`, `6753`, `20403428`, `11126644` ).
address_lookup( `NEWMAN`, `C/-ESS KURRA VILLAGE`, `6753`, `20651289`, `11126644` ).
address_lookup( `YANDI`, `YSP SECURITY GATE`, `6753`, `21491253`, `11126644` ).
address_lookup( `BUNBURY`, `9 STOKES WAY`, `6230`, `22245361`, `11126644` ).

address_lookup( ``, ``, ``, `Missing`, `` ).