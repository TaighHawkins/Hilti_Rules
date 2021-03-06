%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - DE HENNECKE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( de_hennecke, `04 May 2014` ).

i_date_format( _ ).
i_format_postcode( X, X ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number

	, get_delivery_details

	, get_contacts
	
	, get_ddis

	, get_emails
	
	, check( i_user_check( gen_cntr_set, 20, 0 ) )

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
	    , suppliers_code_for_buyer( `10128326` )                      %PROD
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
	  
	  q(0,10,line), generic_vertical_details( [ [ `Bestellnummer`, `/`, `Datum` ], `Bestellnummer`, order_number_and_date, s1, newline ] )
	  
	, check( order_number_and_date = Order_and_Date )
	
	, check( sys_string_split( Order_and_Date, ` / `, [ Order, Date ] ) )
	
	, order_number( Order )
	
	, invoice_date( Date )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACT DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_contacts, [ 
%=======================================================================

	  q(0,15,line), generic_vertical_details( [ [ `Ansprechpartner`, `(`, `in` ], `Ansprechpartner`, buyer_contact, sf, or( [ `/`, tab ] ) ] )
	  
	, check( buyer_contact = Con )
	
	, delivery_contact( Con )

] ).

%=======================================================================
i_rule( get_ddis, [ 
%=======================================================================

	  q(0,15,line), generic_vertical_details( [ [ `(`, `in`, `)`, `/`, `Telefon` ], `Telefon`, end, buyer_ddi_x, s1, newline ] )
	  
	, check( buyer_ddi_x = DDI_X )
	
	, or( [ [ trace( [ `splitting` ] ), check( sys_string_split( DDI_X, `/`, [ Name, DDI ] ) ) ]
	
		, check( DDI_X = DDI )
		
	] )
	
	, buyer_ddi( DDI )
	
	, delivery_ddi( DDI )

] ).

%=======================================================================
i_rule( get_emails, [ 
%=======================================================================

	  q(0,15,line), generic_horizontal_details( [ [ `E`, `-`, `mail`, `:` ], buyer_email, s1, newline ] )
	  
	, check( buyer_email = Email )
	
	, delivery_email( Email )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( delivery_header_line, [ read_ahead( `Anlieferadresse` ), hook(w) ] ).
%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================
	  
	  q(0,15,line), delivery_header_line
	  
	, delivery_thing( [ delivery_party ] )

	, delivery_thing( [ delivery_street ] )
	
	, delivery_postcode_and_city_line
	
] ).


%=======================================================================
i_line_rule( delivery_thing( [ Variable ] ), [
%=======================================================================

	  nearest( hook(start), 10, 10 )
	  
	, Read_Variable

	, trace( [ String, Variable ] )

] ):-

	  Read_Variable =.. [ Variable, s1 ]
	, sys_string_atom( String, Variable )
.

%=======================================================================
i_line_rule( delivery_postcode_and_city_line, [
%=======================================================================

	  delivery_postcode(f( [ begin, q(dec,5,5), end ] ) )
	
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

	  or( [ [ test( no_totals ), total_invoice( `0` ), total_net( `0` ) ]
	  
		, [ q0n(line), generic_horizontal_details( [ [ `Gesamtnettowert`, `ohne`, `Mwst`, `Eur`, tab ], total_invoice, d, newline ] )
	  
			, check( total_invoice = Net )
			
			, total_net( Net )
			
		]
		
	] )

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
i_line_rule_cut( line_end_section_line, [ `Im`, `gesamten` ] ).
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
i_line_rule_cut( line_header_line, [ `Material`, tab, `Bezeichnung` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ or( [ [ `Gesamtnettowert`, `ohne` ], [ `Bankverbindungen` ] ] ) ] ).
%=======================================================================
i_line_rule_cut( underscore_line, [ `_`, `_`, `_` ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	  
	, q10( underscore_line )

	, line_descr_line
	
	, or( [ [ q(0,2, [ q10( underscore_line ), extra_descr_line ] ), line_item_line ]
	
		, line_item( `Missing` ), q(0,2, [ q10( underscore_line ), extra_descr_line ] )
		
	] )
	
	, q(0,6, [ q10( underscore_line ), extra_descr_line ] )
	
	, line_original_order_date_line

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_order_line_number, d, tab ] )

	, generic_item( [ line_quantity, d, q10( tab ) ] )
	
	, or( [ [ generic_item( [ line_quantity_uom_code, s1, tab ] )

			, generic_item( [ line_unit_amount_x, d, [ q10( [ `/`, num(d) ] ), tab ] ] )
			
			, generic_item( [ line_net_amount, d, newline ] )

		]
		
		, [ generic_item( [ line_quantity_uom_code, s1, newline ] ), set( no_totals ) ]
		
	] )
	
] ).

%=======================================================================
i_line_rule_cut( extra_descr_line, [ append( line_descr(s1), ` `, `` ), newline ] ).
%=======================================================================
i_line_rule_cut( line_descr_line, [ generic_item( [ line_descr, s1, tab ] ), q01( [ append( line_descr(s1), ` `, `` ), tab ] ), append( line_descr(s1),` `, `` ), newline ] ).
%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

	  q0n(word), `Nr`, `.`, q10( `:` )
	  
	, generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] )

] ).

%=======================================================================
i_line_rule_cut( line_original_order_date_line, [
%=======================================================================

	  `Liefertermin`, `der`, q0n(anything)
	  
	, generic_item( [ line_original_order_date, date ] )

] ).