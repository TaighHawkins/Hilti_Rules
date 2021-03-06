%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - BE ETERNIT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( be_eternit, `20 October 2014` ).

i_date_format( _ ).
i_format_postcode( X, X ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number
	
	, get_order_date

	, get_delivery_details
	
	, get_delivery_contact
	
	, get_delivery_email

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
	    , suppliers_code_for_buyer( `10096829` )                      %PROD
	]) ]
	
	, sender_name( `Eternit NV` )

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
	  
	  q(0,10,line), generic_horizontal_details( [ [ `Nummer`, `:` ], order_number, s1 ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [
%=======================================================================	  
	  
	  q(0,10,line), generic_horizontal_details( [ [ `Datum`, q10( tab ), `:` ], invoice_date, date ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [ 
%=======================================================================

	  q(0,200,line), delivery_header_line

	, line
	
	, delivery_thing( [ delivery_party ] )
	
	, q10( delivery_thing( [ delivery_dept ] ) )
	
	, delivery_thing( [ delivery_street ] )
	
	, delivery_city_and_postcode_line

] ).


%=======================================================================
i_line_rule( delivery_header_line, [ read_ahead( [ `Leveringsadres` ] ), hook(w)] ).
%=======================================================================
i_rule( delivery_thing( [ Variable ] ), [ q10( gen_line_nothing_here( [ hook(start), 10, 10 ] ) ), delivery_thing_line( [ Variable ] ) ] ).
%=======================================================================
i_line_rule( delivery_thing_line( [ Variable ] ), [
%=======================================================================

	nearest( hook(start), 10, 10 )
	
	, generic_item( [ Variable, s1 ] )

] ).

%=======================================================================
i_line_rule( delivery_city_and_postcode_line, [
%=======================================================================

	nearest( hook(start), 10, 10 )
	
	, generic_item( [ delivery_postcode, [ begin, q(dec,4,5), end ] ] )
	
	, generic_item( [ delivery_city, s1 ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACTS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_email, [ 
%=======================================================================

	  q(0,20,line)
	  
	, generic_horizontal_details( [ [ `E`, `-`, `mail` ], 200, delivery_email, s1 ] )
	
	, check( delivery_email = Email )
	
	, buyer_email( Email )

] ).

%=======================================================================
i_rule( get_delivery_contact, [ 
%=======================================================================

	  q(0,10,line)
	  
	, generic_horizontal_details( [ [ `CONTACT`, `PERSOON`, tab, word, `.` ], delivery_contact, s1 ] )
	
	, check( delivery_contact = Con )
	
	, buyer_contact( Con )

] ).

i_op_param( orders05_idocs_first_and_last_name( buyer_contact, ``, NU ), _, _, _, _) 
:- result( _, invoice, buyer_contact, NU ), string_to_upper(NU, NAME1).

i_op_param( orders05_idocs_first_and_last_name( delivery_contact, ``, NU2 ), _, _, _, _) 
:- result( _, invoice, delivery_contact, NU2 ), string_to_upper(NU2, NAME2).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [ 
%=======================================================================

	  or( [ [ q(0,200,line)
	  
			, generic_horizontal_details( [ [ `Totaal`, `bedrag`, `excl`, `.`, `btw`, tab, `EUR` ], 300, total_net, d ] )
			
		]
		
		, [ total_net( `0` ), set( alt_validation ) ]
		
	] )
	
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
			  
			, line_defect_line

			, line

		] )

	] )
		
	, line_end_line

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ read_ahead( [ `Leveringsdatum`, or( [ tab, `Prijsvraag` ] ), `Hoeveelheid` ] ), header(w) ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================

	or( [ `Totaal` 
	
		, [ q0n( [ dummy(s1), tab ] ), `Facturatie` ]
	
		, [ dummy(w), check( not( dummy(page) = header(page) ) ) ]
		
	] )

] ).

%=======================================================================
i_line_rule_cut( line_defect_line, [ 
%=======================================================================

	num(f( [ q(dec,5,5) ] ) )
	
	, q10( tab ), q10( [ dummy(w), tab ] )
	
	, dummy(s1), newline
	
	, force_result( `defect` )
	
	, force_sub_result( `missed_line` )
	
	, trace( [ `Missed line` ] )

] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	  
	, line_values_line
	
	, or( [ [ test( got_item ), clear( got_item ) ]
	
		, line_item_line
		
		, line_item( `Missing` ) 
		
	] )

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item_cut( [ line_order_line_number, d, q10( tab ) ] )
	
	, q10( generic_item( [ line_item_for_buyer, w, tab ] ) )

	, or( [ [ generic_item( [ line_descr, s, [ generic_item( [ line_item, [ begin, q(dec,4,10), end ], `Hilti` ] ), newline ] ] )
			, set( got_item )
		]
		
		, generic_item( [ line_descr, s1, newline ] )
	] )

] ).

%=======================================================================
i_line_rule_cut( line_values_line, [
%=======================================================================

	  generic_item_cut( [ line_original_order_date, date, tab ] )
	
	, generic_item_cut( [ line_quantity, d, q10( tab ) ] )
	
	, generic_item( [ line_quantity_uom_code, s1, tab ] )

	, or( [ [ generic_item( [ line_unit_amount, d, [ q10( tab ), `/`, q10( tab ), num(s1), tab ] ] )

			, generic_item( [ line_net_amount, d, newline ] )
		
		]
		
		, generic_item( [ some, date, newline ] )
		
	] )

] ).

%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

	  q0n(word)
	  
	, `artikelnummer`, q10( tab )
	
	, generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] )

] ).