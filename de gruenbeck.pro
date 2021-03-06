%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - DE GRUENBECK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( de_gruenbeck, `05 March 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).

i_pdf_parameter( x_tolerance_100, 100 ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	  
	, get_order_number
	
	, get_order_date

	, get_delivery_details

	, get_contact_information

	, get_customer_comments

	, check( i_user_check( gen_cntr_set, 20, 0 ) )
	
	, get_totals

	, get_invoice_lines

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

	, buyer_registration_number( `DE-ADAPTRI` )

	, or( [ 
		[ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	] )

	, or( [ 
		[ test(test_flag), suppliers_code_for_buyer( `10240555` ) ]    %TEST
	    , suppliers_code_for_buyer( `10240555` )                      %PROD
	] )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`5000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, set( reverse_punctuation_in_numbers )
	
	, sender_name( `Gruenbeck Wasseraufbereitung GmbH` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q(0,20,line), generic_horizontal_details( [ [ `Best`, `.`, `Nr`, `.`, `:` ], order_number, s1 ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [
%=======================================================================	  
	  
	  q(0,30,line), generic_horizontal_details( [ [ `Best`, `.`, `-`, `Datum`, `:` ], invoice_date, date ] )
	  
	, check( invoice_date = Date )
	, delivery_date( Date )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACT DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_contact_information, [ 
%=======================================================================

	  q(0,25,line)
	  
	, generic_horizontal_details( [ [ `Sachbearbeiter`, `:` ], buyer_contact, s1 ] )
	, check( buyer_contact = Con )
	, delivery_contact( Con )
	
	, q(0,3,line)
	, q10( [ generic_horizontal_details( [ [ `Telefon`, `:` ], buyer_ddi_x, s1 ] )
		, check( strip_string2_from_string1( buyer_ddi_x, ` -`, DDI ) )
		, buyer_ddi( DDI )
		, delivery_ddi( DDI )
	] )
	
	, q(0,3,line)
	, q10( [ generic_horizontal_details( [ [ `Fax`, `:` ], buyer_fax_x, s1 ] )
		, check( strip_string2_from_string1( buyer_fax_x, ` -`, Fax ) )
		, buyer_fax( Fax )
		, delivery_fax( Fax )
	] )
	
	, q10( [ q(0,3,line)
		, generic_horizontal_details( [ [ `E`, `-`, `Mail`, `:` ], buyer_email, s1 ] )
		, check( buyer_email = Email )
		, delivery_email( Email )
	] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_customer_comments, [ 
%=======================================================================

	  q0n(line)
	  
	, generic_horizontal_details( [ [ or( [ at_start, tab ] ), read_ahead( `Projekt` ), retab( [ 500 ] ) ], customer_comments, s1 ] )
	, check( customer_comments = Com )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [ 
%=======================================================================
	  
	  q0n(line), generic_horizontal_details( [ [ at_start, `Lieferadresse`, `:` ], delivery_party, s1 ] )

	, check( delivery_party(start) = Start )
	, generic_line( [ [ nearest( Start, 10, 10 ), append( delivery_party(s1), ` `, `` ) ] ] )

	, q01( delivery_thing( [ Start, delivery_dept ] ) )

	, delivery_thing( [ Start, delivery_street ] )

	, qn0( gen_line_nothing_here( [ Start, 10, 50 ] ) )
	
	, delivery_street_and_city_line( [ Start ] )
	
] ).

%=======================================================================
i_rule_cut( delivery_thing( [ Start, Var ] ), [ 
%=======================================================================
	
	qn0( gen_line_nothing_here( [ Start, 10, 50 ] ) )
	
	, delivery_thing_line( [ Start, Var ] )
	
] ).

%=======================================================================
i_line_rule( delivery_thing_line( [ Start, Var ] ), [
%=======================================================================

	nearest( Start, 10, 50 )

	, generic_item( [ Var, s1 ] )
	
] ).

%=======================================================================
i_line_rule( delivery_street_and_city_line( [ Start ] ), [
%=======================================================================

	  nearest( Start, 10, 50 )
	  
	, q10( `DE` ), generic_item( [ delivery_postcode, [ begin, q(dec,5,5), end ] ] )
	
	, generic_item( [ delivery_city, s1 ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	q0n(line), generic_horizontal_details( [ [ `Bestellsumme`, qn0(anything), tab ], total_net, d ] )
	
	, check( total_net = Net )
	, total_invoice( Net )

] ).


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

	, q0n(

		or( [ 
		
			  line_invoice_rule
			  
			, line_defect_line

			, line

		] )

	), line_end_line

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `Art`, `-`, `Nr`, `.`, header ] ).
%=======================================================================
i_line_rule_cut( line_defect_line, [ `Pos`, `.`, force_result( `defect` ), force_sub_result( `missed_line` ) ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or( [ [ `Bestellsumme` ]
		
		, `Hausanschrift`
	
		, [ dummy, check( dummy(page) \= header(page) ) ]
		
	] )
	
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_number_line
	  
	, q10( [ test( missing_descr ), generic_line( [ generic_item( [ line_descr, s1 ] ) ] ) ] )
	
	, q(0,2,line)

	, line_values_line
	
	, q0n( line_continuation_line )
	, line_item_line
	
	, clear( missing_descr )
	
] ).

%=======================================================================
i_line_rule_cut( line_number_line, [
%=======================================================================

	  `Pos`, `.`
	  
	, generic_item_cut( [ line_order_line_number, w1, q10( tab ) ] )
	
	, `Eingangsdatum`, `:`
	
	, generic_item( [ line_original_order_date, date, newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_values_line, [
%=======================================================================

	  generic_item_cut( [ line_item_for_buyer, w1, q10( tab ) ] )
	
	, or( [ generic_item( [ line_descr, s1, tab ] ), set( missing_descr ) ] )

	, generic_item_cut( [ line_quantity, d ] )
	, generic_item( [ line_quantity_uom_code, s1, tab ] )

	, generic_item( [ line_unit_amount, d, tab ] )
	, q(1,2,[ some(d), tab ] )
	
	, generic_item( [ line_net_amount, d, newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_continuation_line, [ append( line_descr(s1), ` `, `` ), newline ] ).
%=======================================================================
i_line_rule_cut( line_item_line, [ 
%=======================================================================

	  qn0(
		or( [
			`Ihre`
			, `Materialnummer`
			, `Best`
			, `Nr`
			, `.`
			, `:`
		] )
	)
	, generic_item( [ line_item, [ begin, q(dec,4,10), end ], [ q(0,2,word), newline ] ] )
	
] ).
