%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - BE EANDIS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( be_eandis, `20 October 2014` ).

i_date_format( _ ).
i_format_postcode( X, X ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number

	, get_delivery_details
	
	, get_delivery_contact

	, get_invoice_lines

	, get_totals
	
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

	, buyer_registration_number( `BE-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`0700`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10086426` ) ]    %TEST
	    , suppliers_code_for_buyer( `10107455` )                      %PROD
	]) ]
	
	, delivery_party( `EANDIS CVBA.` )
	, sender_name( `Eandis CVBA.` )

	, set( reverse_punctuation_in_numbers )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q(0,10,line)
	  
	, generic_vertical_details( [ [ `Bestelnummer`, `/`, `datum` ], order_number_x, s1 ] )
	
	, check( i_user_check( split_the_date, order_number_x, Order, Date ) )
	
	, order_number( Order )
	, invoice_date( Date )
	
	, trace( [ `Order info`, Order, Date ] )
	
] ).

%=======================================================================
i_user_check( split_the_date, String_In, Order, Date )
%-----------------------------------------------------------------------
:- strip_string2_from_string1( String_In, ` `, String_Strip ), sys_string_split( String_Strip, `/`, [ Order, Date ] ).
%=======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [ 
%=======================================================================

	  q(0,25,line), delivery_header_line
	  
	, check( hook(start) = Start )
	
	, check( sys_calculate( Left, Start - 10 ) )
	
	, q(1,2,line), q10( gen_line_nothing_here( [ hook(start), 10, 10 ] ) )
	
	, or( [ delivery_thing( 1, Left, -100, [ delivery_dept ] )

		, line
		
	] )
	
	, q10( gen_line_nothing_here( [ hook(start), 10, 10 ] ) ), delivery_thing( 1, Left, -100, [ delivery_street ] )
	
	, q10( gen_line_nothing_here( [ hook(start), 10, 10 ] ) ), delivery_city_and_postcode_line( 1, Left, -100 )

] ).


%=======================================================================
i_line_rule( delivery_header_line, [ read_ahead( [ `Leveringsplaats` ] ), hook(w)] ).
%=======================================================================
i_line_rule( delivery_thing( [ Variable ] ), [
%=======================================================================

	  read_ahead( dummy(s1) )
	  
	, check( i_user_check( check_no_lowercase, dummy ) )

	, generic_item( [ Variable, s1 ] )

] ).

%=======================================================================
i_user_check( check_no_lowercase, In )
%-----------------------------------------------------------------------
:- not( q_regexp_match( `.+[a-z].+`, In, _ ) ).
%=======================================================================

%=======================================================================
i_line_rule( delivery_city_and_postcode_line, [
%=======================================================================

	  generic_item( [ delivery_postcode, [ begin, q(dec,4,5), end ] ] )
	  
	, generic_item( [ delivery_city, s1 ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACTS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_contact, [ 
%=======================================================================

	  q(0,200,line)
	  
	, generic_horizontal_details( [ [ `CONTACTPERSOON`, `:` ], delivery_contact_x, s1 ] )
	
	, check( i_user_check( reverse_names, delivery_contact_x, Con ) )
	
	, delivery_contact( Con )
	, buyer_contact( Con )

] ).

%=======================================================================
i_user_check( reverse_names, Names_In, Names_Out ):- 
%=======================================================================
  
	  strip_string2_from_string1( Names_In, `,`, Names_In_Strip )  
	, sys_string_split( Names_In_Strip, ` `, [ Surname, Names ] ) 

	, wordcat( [ Names, Surname ], Names_Out )
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [ 
%=======================================================================

	  q(0,200,line)
	  
	, generic_horizontal_details( [ [ `Totale`, `nettowaarde`, `excl`, `.`, `btw`, `:`, `EUR` ], 800, total_net, d ] )
	
	, check( total_net = Net )
	
	, total_invoice( Net )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line
	 
	, trace( [ `found header` ] )

	, q0n( [

		  or( [ 
		
			  line_invoice_rule

			, line

		] )

	] )
		
	, line_end_line

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `N°`, q10( tab ), `Artikel` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `Totale` ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	  
	, line_values_line
	
	, q(0,10,line)
	
	, or( [ line_item_line
	
		, [ line_check_line, line_item( `Missing` )	
			, trace( [ `Line item`, line_item ] )
		]
		
	] )

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_order_line_number, d, q10( tab ) ] )
	
	, generic_item( [ line_item_for_buyer, [ begin, q(dec,4,10), end ] ] )

	, generic_item( [ line_descr, s1, newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_values_line, [
%=======================================================================

	  generic_item_cut( [ line_quantity, d, q10( tab ) ] )
	
	, generic_item( [ line_quantity_uom_code, s1, tab ] )

	, generic_item( [ line_unit_amount, d, [ q10( [ `/`, num(d) ] ), tab ] ] )

	, generic_item( [ line_net_amount, d, newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

	  q0n(word)
	  
	, or( [ [ `artikelnummer` ]
	
		, [ `artnr`, `:` ]
		
	] )
	
	, generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] )

] ).

%=======================================================================
i_line_rule_cut( line_check_line, [ 
%=======================================================================

	or( [ [ dummy(f([q(dec,3,3)])), q10( tab ), dummy(s1), newline  ]
	
		, [ `CONTACTPERSOON` ]
		
	] )
	
] ).