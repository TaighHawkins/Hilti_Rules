%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - DE IPS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( de_ips, `20 March 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	get_fixed_variables

	, get_order_number

	, get_order_date

	, get_totals
	
	, check_for_delivery_address

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHECK FOR DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( check_for_delivery_address, [
%=======================================================================	  
	  
	  q0n(line), generic_line( [ `Lieferadresse` ] )
	  
	, delivery_note_reference( `special_rule` )
	, set( do_not_process )
	
	, trace( [ `Delivery address found - document NOT processed` ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	get_due_date

	, get_contacts
	
	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

] ):- not( grammar_set( do_not_process ) ).


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

	, buyer_registration_number( `DE-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`5000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10267671` ) ]    %TEST
	    , suppliers_code_for_buyer( `20023895` )                      %PROD
	]) ]

	, [ or([ 
	  [ test(test_flag), delivery_note_number( `10267671` ) ]    %TEST
	    , delivery_note_number( `20556158` )                      %PROD
	]) ]
	
	, set( reverse_punctuation_in_numbers )
	
	, sender_name( `Industrial Piping Service` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q(0,20,line), generic_horizontal_details( [ [ `Bestellung`, `Nr`, `.` ], order_number, s1, gen_eof ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [
%=======================================================================	  
	  
	  q(0,20,line), generic_horizontal_details( [ [ `Burghausen`, `,`, `den` ], invoice_date, date ] )
	
] ).

%=======================================================================
i_rule( get_due_date, [
%=======================================================================	  
	  
	  q0n(line), generic_horizontal_details( [ [ `Liefertermin`, tab, `:` ], due_date, date ] )
	  
	, set( new_format )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACT DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_contacts, [ 
%=======================================================================

	  q(0,15,line), buyer_contact_line
	  
	, generic_horizontal_details( [ [ `Tel`, `.`, tab, `:` ], ddi, s1, newline ] )
	
	, check( string_string_replace( ddi, `+49`, `0`, DDI ) )
	
	, buyer_ddi( DDI )
	
	, delivery_ddi( DDI )
	
	, generic_horizontal_details( [ [ `Fax`, `.`, tab, `:` ], fax, s1, newline ] )
	
	, generic_horizontal_details( [ [ `E`, `-`, `Mail`, tab, `:` ], buyer_email, s1, newline ] )
	
	, check( buyer_email = Email )
	
	, delivery_email( Email )

] ).

%=======================================================================
i_line_rule( buyer_contact_line, [ 
%=======================================================================

	  q10( [ dummy(s1), tab ] )
	  
	, generic_item( [ buyer_contact, s1, newline ] )
	
	, check( buyer_contact = Con )
	
	, delivery_contact( Con )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  qn0(line), generic_horizontal_details( [ [ `Nettobetrag`, tab, `EUR` ], total_invoice, d, newline ] )
	  
	, check( total_invoice = Inv )
	
	, total_net( Inv )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section_control( get_invoice_lines, first_one_only ).
%=======================================================================
i_section_end( get_invoice_lines, line_end_section_line ).
%=======================================================================
i_line_rule_cut( line_end_section_line, [ `Zwischensumme` ] ).
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
i_line_rule_cut( line_header_line, [ `Pos`, tab, `Anzahl` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `Nettobetrag` ] ).
%=======================================================================
i_line_rule_cut( line_ubertrag_line, [ `Übertrag` ] ).
%=======================================================================
i_rule_cut( carried_forward_rule( [ Rule ] ), [ q10( line_ubertrag_line ), Rule ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	  
	, or( [ [ q0n( carried_forward_rule( [ line_continuation_line ] ) )
	
			, carried_forward_rule( [ line_item_line ] )

			, q0n( carried_forward_rule( [ line_continuation_line ] ) )
			
		]
		
		, [ line_item( `Missing` )
		
			, q0n( carried_forward_rule( [ line_continuation_line ] ) )
			
		]
		
	] )
	
	, or( [ carried_forward_rule( [ line_date_line ] )
	
		, [ test( new_format ), with( invoice, due_date, Date )
			, line_original_order_date( Date )
		]
	] )
	
	, check( line_item = Item )
	
	, or( [ [ check( Item = `420116` )
			, check( sys_calculate_str_divide( line_quantity_x, `20`, Qty ) )
		]
		
		, check( line_quantity_x = Qty )
		
	] )
	
	, line_quantity( Qty )

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_order_line_number, d, tab ] )

	, generic_item_cut( [ line_quantity_x, d, q10( tab ) ] )
	
	, generic_item( [ line_quantity_uom_code, w, q10( tab ) ] )
	
	, generic_item( [ line_descr, s1, tab ] )

	, generic_item_cut( [ line_unit_amount, d, tab ] )
	
	, q10( generic_item( [ line_price_uom_code, w, tab ] ) )
	
	, q10( generic_item( [ line_percent_discount, d, [ `%`, tab ] ] ) )

	, generic_item( [ line_net_amount, d, newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_continuation_line, [ append( line_descr(s1), `~`, `` ), q01( [ tab, append( line_descr(s1), ` `, `` ) ] ), newline ] ).
%=======================================================================
i_line_rule_cut( line_descr_line, [ generic_item( [ line_descr, s1, tab ] ), q01( [ append( line_descr(s1), ` `, `` ), tab ] ), append( line_descr(s1),` `, `` ), newline ] ).
%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

	  `Herst`, `.`, `Art`, `.`, q10( `:` ), q10( tab )
	  
	, generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] )

] ).

%=======================================================================
i_line_rule_cut( line_date_line, [
%=======================================================================

	  `Liefertermin`, `:`
	
	, generic_item( [ line_original_order_date, date ] )

] ).