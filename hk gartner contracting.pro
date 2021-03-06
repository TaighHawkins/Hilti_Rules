%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - HK GARTNER CONTACTING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( hk_gartner_contracting, `18 August 2015` ).

i_date_format( _ ).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).
i_user_field( invoice, delivery_district, `Delivery District` ).
i_user_field( invoice, type_of_supply, `Type of Supply` ).

i_orders05_idocs_e1edkt1( `Z011`, picking_instructions ).
i_user_field( invoice, picking_instructions, `Picking Instructions` ).
i_orders05_idocs_e1edkt1( `Z012`, packing_instructions ).
i_user_field( invoice, packing_instructions, `Packing Instructions` ).

i_user_field( invoice, contact_first_name, `Contact First Name` ).
i_user_field( invoice, contact_last_name, `Contact Last Name` ).
i_op_param( orders05_idocs_first_and_last_name( CONTACT, NAME1, NAME2 ), _, _, _, _ )
:-
	q_sys_member( CONTACT, [ buyer_contact, delivery_contact ] ),
	result( _, invoice, contact_first_name, NAME1 ),
	result( _, invoice, contact_last_name, NAME2 ),
	!
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_gartner_co
	
	, get_order_number
	, get_invoice_date
	
	, get_delivery_lookup

	, get_contact_lookup

	, get_invoice_lines

	, gen_vert_capture( [ [ `TOTAL`, `AMOUNT`, `IN`, `HKD` ], `HKD`, end, total_net, d, newline ] )
	, gen_vert_capture( [ [ `TOTAL`, `AMOUNT`, `IN`, `HKD` ], `HKD`, end, total_invoice, d, newline ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIXED VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [
%=======================================================================

	  buyer_party( `LS` )

	, supplier_party( `LS` )

	, buyer_registration_number( `HK-ADAPTRI` )

	, [ or([
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, [ or([
	  [ test(test_flag), suppliers_code_for_buyer( `11202429` ) ]    %TEST
	    , suppliers_code_for_buyer( `10559830` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`2300`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, sender_name( `Gartner Contracting Co. Ltd.` )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_gartner_co, [
%=======================================================================

	  or( [
	
		[ q(0,3,line), generic_horizontal_details( [ [ `Bill`, `to`, `:` ] ] )
			, q01(line), gartner_co_line
		]
		
		, [ delivery_note_reference( `FAIL` ), trace( [ `NO GARTNER CO` ] ) ]
		
	] )

] ).

%=======================================================================
i_line_rule( gartner_co_line, [
%=======================================================================

	  nearest( generic_hook(start), 0, 20 )
	
	, `GARTNER`, `CONTRACTING`, `Co`, `.`, `Ltd`, trace( [ `FOUND GARTNER CO` ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================

	  q(0,30,line)
	
	, generic_vertical_details( [ [ `PO`, `Number`, tab, `Rev` ], `PO`, q(0,3), start, order_number, s1 ] )
	
	, check( sys_string_length( order_number, Length ) )
	, check( Length > 0 )
	, check( not( q_sys_sub_string( order_number, _, _, `<` ) ) )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET INVOICE DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_date, [
%=======================================================================

	  q(0,30,line)
	
	, generic_vertical_details( [ [ `PO`, `Date`, tab, `PO` ], `Date`, q(0,3), start, invoice_date, date ] )
	
	, check( sys_string_length( invoice_date, Length ) )
	, check( Length > 0 )
	, check( not( q_sys_sub_string( invoice_date, _, _, `<` ) ) )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET DELIVERY LOOKUP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_lookup, [
%=======================================================================

	  q(0,3,line)
	
	, delivery_header_line
	
	, q0n( or( [
	
			delivery_para_line

			, gen_line_nothing_here( [ delivery_hook(start), 10, 30 ] )
		
	] ) )
	
	, or( [
	
		generic_horizontal_details( [ contact, sf, [ `(`, `Tel` ] ] )
		
		, generic_horizontal_details( [ [ `Project`, `-`, `Number` ] ] )
		
	] )
	
	, trace( [ `Complete delivery para`, delivery_para ] )
	
	, check( i_user_check( get_delivery_note_number, delivery_para, Delivery_note_number ) )
	
	, delivery_note_number( Delivery_note_number )
	, trace( [ `delivery_note_number`, delivery_note_number ] )

] ).

%=======================================================================
i_line_rule( delivery_header_line, [
%=======================================================================

	  q0n( [ a(s1), tab ] )
	
	, read_ahead( [ `Please`, `Deliver`, `to`, `:` ] )
	
	, generic_item( [ delivery_hook, s1 ] )

] ).

%=======================================================================
i_line_rule_cut( delivery_para_line, [
%=======================================================================

	  nearest( delivery_hook(start), 10, 30 )
	
	, or( [
	
		[ test( para ), append( delivery_para(s1), ` `, `` ) ]
		
		, [ generic_item( [ delivery_para, s1 ] ), set( para ) ]
		
	] )

] ).

%-----------------------------------------------------------------------
i_user_check( get_delivery_note_number, Delivery_para, Delivery_note_number )
%-----------------------------------------------------------------------
:-
	string_to_upper( Delivery_para, DELIVERY_PARA ),
	strip_string2_from_string1( DELIVERY_PARA, `,`, PARA ),
	trace( para( PARA ) ),
	delivery_lookup( Delivery_note_number, ADDRESS ),
	trace( address( ADDRESS ) ),
	q_sys_sub_string( PARA, _, _, ADDRESS ),
	!
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET CONTACT LOOKUP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_contact_lookup, [
%=======================================================================

	  or( [
	
		[ q(0,7,line), delivery_header_line, q(0,4,line), contact_line_1 ]

		, [ q(0,30,line), contact_header_line_2, q(0,2,line), contact_line_2 ]
		
	] )
	
	, check( i_user_check( get_contact_info, ddi, Delivery_note_number, Last_name, First_name, Contact, DDI_clean ) )
	
	, buyer_contact( Contact ), delivery_contact( Contact )
	, buyer_ddi( DDI_clean ), delivery_ddi( DDI_clean )
	
	, contact_first_name( First_name )
	, contact_last_name( Last_name )
	
	, buyer_location( Delivery_note_number )

	, delivery_from_location( Delivery_note_number )
	, trace( [ `delivery_from_location`, delivery_from_location ] )
	
	, trace( [ `got contact info` ] )

] ).

%=======================================================================
i_line_rule( contact_line_1, [
%=======================================================================

	  nearest( delivery_hook(start), 10, 30 )
	
	, peek_fails( [ `Deliver`, `to` ] )
	
	, generic_item( [ contact, sf, [ `(`, `Tel`, `:`, read_ahead( a(d) ) ] ] )
	
	, generic_item( [ ddi, sf, or( [ `)`, gen_eof ] ) ] )

] ).

%=======================================================================
i_line_rule( contact_header_line_2, [
%=======================================================================

	  q0n( [ a(s1), tab ] )
	
	, `Delivery`, `Date`, tab, read_ahead( `Contact` )
	
	, generic_item( [ contact_hook_1, s1 ] )

] ).

%=======================================================================
i_line_rule( contact_line_2, [
%=======================================================================

	  nearest( contact_hook_1(start), 10, 30 )
	
	, peek_fails( `<` )
	
	, generic_item( [ contact, sf, [ q10( `-` ), read_ahead( a(d) ) ] ] )
	
	, generic_item( [ ddi, s1 ] )

] ).

%-----------------------------------------------------------------------
i_user_check( get_contact_info, DDI, Buyer_location, Last_name, First_name, Contact, DDI_clean )
%-----------------------------------------------------------------------
:-
	strip_string2_from_string1( DDI, ` `, DDI_1 ),
	(
		q_sys_sub_string( DDI_1, 1, 3, `852` )
		-> q_sys_sub_string( DDI_1, 4, _, DDI_clean )
		;
		DDI_1 = DDI_clean
	),
	contact_lookup( Buyer_location, Last_name, First_name, DDI_clean ),
	strcat_list( [ First_name, ` `, Last_name ], Contact ),
	!
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line

	, q0n(

		or( [
		
			line_invoice_rule
			
			, line_discount_line
	
			, line

		] )

	)

	, line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [
%=======================================================================

	  `Item`, tab, `Description`, tab, `Order`
	
] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	  or( [
	
		[ `For`, `and`, `On`, `behalf` ]
		
		, [ `Round`, `down` ]
		
	] )
	
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line

	, q01(line)
	
	, line_item_line
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_no( [ line_order_line_number, d, tab ] )
	  
	, generic_item( [ line_descr, s1, tab ] )
	
	, generic_no( [ line_quantity, d, tab ] )
	
	, generic_item( [ line_quantit_uom_code, s1, tab ] )
	
	, generic_no( [ line_unit_amount, d, tab ] )
	
	, generic_no( [ line_net_amount, d, newline ] )
	
] ).

%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

	  `Item`
	
	, or( [
	
		[ `Code`, `:` ]
		
		, [ `No`, `.` ]
		
	] )
	
	, generic_item( [ line_item, s1, newline ] )
	
] ).

%=======================================================================
i_line_rule_cut( line_discount_line, [
%=======================================================================

	  a(s1), tab
	  
	, generic_item( [ line_descr, s1, tab ] )
	
	, generic_no( [ line_net_amount, d, newline ] )
	
	, line_type( `ignore` )
	
	, set( no_total_validation )
	
] ).

%-----------------------------------------------------------------------
% Delivery Lookup
%-----------------------------------------------------------------------
delivery_lookup( `20273687`, `COMPANY GARTNER CONTRACTING CO. LTD PERMASTEELISA INTERIORS PACIFIC ROOM 2701-07B ISLAND PLACE TOWER 510 KING'S ROAD NORTH POINT` ).
delivery_lookup( `20273687`, `ROOM 2701-07B ISLAND PLACE TOWER 510 KING'S ROAD NORTH POINT` ).
delivery_lookup( `20474024`, `DELIVER TO VALENTINO CANTON ROAD SITE` ).
delivery_lookup( `20474024`, `DFS HONG KONG TST CHINACHEM PLAZA` ).
delivery_lookup( `20474024`, `CHANEL SHOP NO. 28 CANTON ROAD TSIM SHA TSUI KOWLOON HK` ).
delivery_lookup( `20521967`, `BERLUTI SHOP PRINCES BUILDING 10 CHARTER ROAD CENTRAL HK` ).
delivery_lookup( `21357960`, `G/F. SHUI SUM IND. BLDG. 453-457 CASTLE PEAK ROAD KWAI CHUNG HK` ).
delivery_lookup( `21425923`, `CHANEL SHOP HONG KONG HYSAN PLACE CASUSEWAY BAY HONG KONG` ).
delivery_lookup( `21425953`, `FENDI SHOP G/F THE LANDMARK DES VOEUX ROAD CENTRAL HONG KONG` ).
delivery_lookup( `21491705`, `時代廣場地下近堅拿道東和霎東街` ).
delivery_lookup( `21800269`, `SOGO HONG KONG BOTTEGA VENETA SITE NEAR EAST POINT ROAD` ).
delivery_lookup( `22353525`, `H&M HANG LUNG CENTRE 2-20 PATERSON STREET CAUSEWAY BAY` ).
delivery_lookup( `22440579`, `HARBOUR CITY CANTON RD COACH SHOP` ).


%-----------------------------------------------------------------------
% Contact Lookup
%-----------------------------------------------------------------------
contact_lookup( `15602779`, `MR`, `AH KIN`, `93435510` ).
contact_lookup( `14100955`, `MR`, `AH MING`, `94228033` ).
contact_lookup( `16636087`, `MR`, `AH MING`, `97744544` ).
contact_lookup( `15722977`, `MR`, `AH WING`, `93368577` ).
contact_lookup( `10892770`, `MR`, `BARRY`, `62926888` ).
contact_lookup( `16415322`, `MR`, `BUTT`, `39008939` ).
contact_lookup( `13754152`, `MR`, `CHAN`, `93006538` ).
contact_lookup( `14034327`, `MR`, `CHAN`, `97756101` ).
contact_lookup( `17823952`, `MR`, `CHOY`, `90552062` ).
contact_lookup( `14793408`, `MR`, `CHUEN GOR`, `96836300` ).
contact_lookup( `15327472`, `MR`, `CHUNG`, `63595162` ).
contact_lookup( `14035229`, `MR`, `CHUNG`, `65228493` ).
contact_lookup( `14063583`, `MR`, `LEE`, `39008310` ).
contact_lookup( `14150406`, `MR`, `LEE`, `91680787` ).
contact_lookup( `14103978`, `MR`, `LEE`, `93846362` ).
contact_lookup( `16460998`, `MR`, `LEUNG`, `39008985` ).
contact_lookup( `15959186`, `MR`, `MING`, `60900982` ).
contact_lookup( `16838498`, `MR`, `MING`, `69892116` ).
contact_lookup( `12403595`, `MR`, `RYAN`, `60234807` ).
contact_lookup( `14034326`, `MR`, `TONG`, `61085528` ).
contact_lookup( `15189580`, `MR`, `WONG`, `66300101` ).
contact_lookup( `14669035`, `MR`, `YIP`, `96899786` ).
contact_lookup( `11518707`, `MR CHAN`, `ALEX`, `66137091` ).
contact_lookup( `8978022`, `MR CHAN`, `ALEX`, `98402300` ).
contact_lookup( `16287674`, `MR CHAN`, `JACKY`, `96573102` ).
contact_lookup( `9419475`, `MR CHAN`, `MUI HING`, `66631844` ).
contact_lookup( `15792748`, `MR CHAN`, `TENRIC`, `39008358` ).
contact_lookup( `16041543`, `MR CHAO`, `WA`, `91830132` ).
contact_lookup( `15473274`, `MR CHENG`, `EDDIE`, `98695711` ).
contact_lookup( `11052473`, `MR CHEUNG`, `WILLLIAM`, `98422814` ).
contact_lookup( `9428524`, `MR CHOW`, `WAI WAH`, `62331273` ).
contact_lookup( `15917341`, `MR FUNG`, `ALEX`, `93846303` ).
contact_lookup( `17590550`, `MR FUNG`, `METTHEW`, `68325885` ).
contact_lookup( `17605539`, `MR KONG`, `JEREMY`, `66888019` ).
contact_lookup( `15948762`, `MR KWONG`, `LEWIS`, `94067441` ).
contact_lookup( `14866843`, `MR LAW`, `KEN`, `93846330` ).
contact_lookup( `17425504`, `MR LEE`, `KEITH`, `96851398` ).
contact_lookup( `14059983`, `MR LEUNG`, `JOY`, `39008321` ).
contact_lookup( `15685867`, `MR LEUNG`, `MARK`, `93875366` ).
contact_lookup( `16289308`, `MR LEUNG`, `MARK`, `95529940` ).
contact_lookup( `15163096`, `MR LI`, `VENNIS`, `39008321` ).
contact_lookup( `15833651`, `MR MAN`, `BARRY`, `97232187` ).
contact_lookup( `13754137`, `MR PANG`, `PAUL`, `92627579` ).
contact_lookup( `10892890`, `MR TSE`, `AH WING`, `61397117` ).
contact_lookup( `18078698`, `MR WONG`, `ALEX`, `93129106` ).
contact_lookup( `17954644`, `MR WONG`, `KAY`, `60981894` ).
contact_lookup( `13886460`, `MR WONG`, `SIMSON`, `98562080` ).
contact_lookup( `14406209`, `MR YEUNG`, `KEN`, `93846339` ).
contact_lookup( `14878756`, `MR YING`, `MARCO`, `61527011` ).
contact_lookup( `15676800`, `MR YING`, `MARCO`, `98650086` ).
contact_lookup( `15846802`, `MR YIU`, `JACKY`, `35206420` ).
contact_lookup( `9547285`, `MS`, `HO`, `35798292` ).
contact_lookup( `14465148`, `MS`, `HUI`, `22419251` ).
contact_lookup( `12560566`, `MS`, `TONG`, `24828229` ).
contact_lookup( `16554106`, `MS`, `YEUNG`, `22419284` ).
contact_lookup( `15057854`, `MS CHAN`, `ADA`, `39008392` ).
contact_lookup( `10535353`, `MS CHEUNG`, `VILLIE`, `39008398` ).
contact_lookup( `15672130`, `MS LAU`, `HEIDI`, `39008348` ).
contact_lookup( `14922210`, `MS YIU`, `WENDY`, `35206428` ).
contact_lookup( `18736754`, `MR HO`, `WING HANG`, `69883036` ).