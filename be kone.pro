%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - BE KONE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( be_kone, `07 November 2014` ).

i_date_format( _ ).
i_format_postcode( X, X ).

i_user_field( line, line_descr_x, `Temporary line description` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number
	
	, get_order_date

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
	    , suppliers_code_for_buyer( `10071784` )                      %PROD
	]) ]

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
	  
	  q(0,100,line)
	  
	, generic_vertical_details( [ [ `N`, `°`, `Commande` ], `N`, order_number, s1, tab ] )
	  
] ).

%=======================================================================
i_rule( get_order_date, [
%=======================================================================

	  q(0,100,line)
	  
	, or( [ generic_vertical_details( [ [ `Date`, tab ], `Date`, invoice_date, date, tab ] )
	
		, [ generic_vertical_details( [ [ `Date`, tab ], `Date`, all_the_dates, s1, newline  ] )
		
			, check( i_user_check( split_the_date, all_the_dates, Date ) )
			
			, invoice_date( Date )
			
		]
		
	] )
	  
] ).

%=======================================================================
i_user_check( split_the_date, String_In, Date )
%-----------------------------------------------------------------------
:- sys_string_split( String_In, ` `, [ Date | _ ] ).
%=======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [ 
%=======================================================================

	  q(0,100,line), delivery_header_line
	  
	, check( hook(start) = Start )
	
	, check( sys_calculate( Left, Start - 10 ) )
	  
	, delivery_thing( 1, Left, -100, [ delivery_party ] )
	
	, q10( delivery_thing( 1, Left, -100, [ delivery_dept ] ) )
	
	, delivery_thing( 1, Left, -100, [ delivery_street ] )
	
	, delivery_city_and_postcode_line( 1, Left, -100 )

] ).


%=======================================================================
i_line_rule( delivery_header_line, [ read_ahead( [ `Adresse`,`de`, `livraison` ] ), hook(w)] ).
%=======================================================================
i_line_rule( delivery_thing( [ Variable ] ), [
%=======================================================================

	  Read_Var
	  
	, trace( [ String, Variable ] )

] ):-

	Read_Var =.. [ Variable, s1 ]
	, sys_string_atom( String, Variable )
.

%=======================================================================
i_line_rule( delivery_city_and_postcode_line, [
%=======================================================================

	  q10( delivery_postcode( f( [ q(any,0,20), begin, q(dec,4,5), end ] ) ) )
	  
	, delivery_city(s1)
	
	, trace( [ `delivery stuffs`, delivery_city, delivery_postcode ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_contact, [ 
%=======================================================================

	  q(0,100,line)
	  
	, generic_horizontal_details( [ read_ahead( `Acheteur` ), contact_hook, s1 ] )
	
	, generic_horizontal_details( [ [ nearest_word( contact_hook(start), 5, 5 ) ], delivery_contact, s1, tab ] )
	
	, check( delivery_contact = Con )
	
	, buyer_contact( Con )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [ 
%=======================================================================

	  last_line, q(0,50,up)
	  
	, generic_vertical_details( [ [ `Tot`, `.`, `Brut` ], `Tot`, start, 100, 0, total_net, d, gen_eof ] )
	
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
i_line_rule_cut( line_header_line, [ `Pos`, `.`, `Ref` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ qn0(anything), `Tot`, `.` ] ).
%=======================================================================
i_line_rule_cut( line_check_line, [ q0n(anything), some(date) ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	  
	, line_uom_line
	
	, check( line_descr_y = Descr_y )
	
	, or( [ [ test( got_item )
	
			, gen1_parse_text_rule( [ -500, 500, or( [ line_end_line, line_check_line ] )
												, any, [ begin, q(any,1,10), end ]
											] )
											
		]
		
		, [ gen1_parse_text_rule( [ -500, 500, or( [ line_end_line, line_check_line ] )
												, line_item, [ begin, q(dec,4,10), end ]
											] )
											
		]
		
	] )

	, check( captured_text = Descr_Z )
	
	, or( [ [ test( no_descr ), check( Descr = Descr_Z ) ]
	
		, [ check( line_descr_y = Descr_y )
	
			, check( strcat_list( [ Descr_y, ` `, Descr_Z ], Descr ) )
			
		]
		
	] )
	
	, or( [ [ test( got_item ), line_descr( Descr )
	
			, trace( [ `Full description`, line_descr ] )
			
		]
		
		, [ line_descr_x( Descr )
	
			, trace( [ `Description`, line_descr_x ] )
			
		]
		
	] )
	
	, clear( got_item )
	
	, clear( no_descr )

] ).

%=======================================================================
i_line_rule_cut( line_uom_line, [
%=======================================================================

	  or( [ 
	   		
		 [ q10( `#` ), generic_item( [ line_item, [ begin, q(dec,4,10), end ], tab ] ), set( no_descr ), set( got_item ) ]
	  
		, [ generic_item( [ line_descr_y, s, q10( tab ) ] )
	  
			, generic_item( [ line_item, [ begin, q(dec,4,10), end ], tab ] ), set( got_item ) 
			
		]
		
		, [ q10( `#` ), generic_item( [ line_item, [ begin, q(dec,4,10), end ], tab ] ), set( no_descr ), set( got_item ) ]
	
		, generic_item( [ line_descr_y, s1, tab ] )
		
	] )

	, num(d), word, newline

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_order_line_number, d, q10( tab ) ] )
	
	, q10( generic_item( [ line_item_for_buyer, s1, tab ] ) )

	, generic_item( [ line_original_order_date, date, tab ] )

	, generic_item( [ line_quantity, d, q01( tab ) ] )
	
	, generic_item( [ line_quantity_uom_code, s1, tab ] )

	, generic_item( [ line_unit_amount, d, [ `/`, tab ] ] )

	, generic_item( [ line_net_amount, d, newline ] )

] ).


%=======================================================================
i_analyse_line_fields_first( LID ) :-
%--------------------------------------------------------------
i_analyse_line_line_descriptions__( LID ).
%=======================================================================

%=======================================================================
i_analyse_line_line_descriptions__( LID )
%--------------------------------------------------------------
:-
%=======================================================================

	  result( _, LID, line_descr_x, Text )
	  
	, string_string_replace( Text, `#`, ` # `, Text_1 )
	, sys_string_split( Text_1, ` `, Text_List )
	
	, sys_append( _, [ Item | _ ], Text_List )
	, q_regexp_match( `([\\d]{4,})`, Item, _ )
	
	, compare_lists( Text_List, [ Item ], Text_List_Without_Item )
	
	, pull_apart_remainder( Text_List_Without_Item, Descr )	
	
	, assertz_derived_data( LID, line_descr, Descr, manipulate_description )

	, !
.

pull_apart_remainder( Text_In_List, Text_Out_String ):-
	
	  sys_stringlist_concat( Text_In_List, ` `, Text_In_String )
	, strip_string2_from_string1( Text_In_String, `#`, Text_In_String_1 )
	, string_string_replace( Text_In_String_1, ` / `, ` `, Text_In_String_2 )
	, string_string_replace( Text_In_String_2, `REF`, `` , Text_In_String_3 )
	, string_string_replace( Text_In_String_3, `Referentie Hilti:`, `` , Text_Out_String )
	
.
