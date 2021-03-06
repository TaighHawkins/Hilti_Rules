%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - IT SITI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( it_siti, `15 April 2014` ).

i_date_format( _ ).
i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number_and_date

	, get_delivery_details
	
	, get_buyer_contact
	
	, get_delivery_contact
	
	, get_buyer_email

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

	, buyer_registration_number( `IT-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`7500`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10658906` ) ]    %TEST
	    , suppliers_code_for_buyer( `12964286` )                      %PROD
	]) ]

	, [ or([ 
	  [ test(test_flag), delivery_note_number( `10658906` ) ]    %TEST
	    , delivery_note_number( `12914727` )                      %PROD
	]) ]

	, set( reverse_punctuation_in_numbers )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number_and_date, [
%=======================================================================	  
	  
	  q(0,5,line), generic_vertical_details( [ [ `Numero`, tab, `Data` ], `Numero`, start, 5, 20, order_number_and_date, s1, tab ] )
	  
	, check( sys_string_split( order_number_and_date, ` `, [ Num, Date ] ) )
	
	, invoice_date( Date )
	
	, order_number( Num )
	
	, trace( [ `order number and date`, order_number, invoice_date ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [
%=======================================================================

	  q(0,5,line), generic_vertical_details( [ [ `Numero`, tab, `Data` ], `Data`, start, invoice_date, date, tab ] )
	  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACT DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ q(0,30,line), buyer_contact_line ] ).
%=======================================================================
i_line_rule( buyer_contact_line, [
%=======================================================================

	  q0n(anything), `Acquisitore`, tab, word, tab
	  
	, surname(w)
	
	, buyer_contact(s1)
	
	, check( surname = Sur )
	
	, append( buyer_contact( Sur ), ` `, `` )
	
	, trace( [ `buyer contact`, buyer_contact ] )

] ).

%=======================================================================
i_rule( get_delivery_contact, [ with( invoice, buyer_contact, Con ), delivery_contact( Con ) ] ).
%=======================================================================

%=======================================================================
i_rule( get_buyer_email, [ 
%=======================================================================

	  q(0,30,line), generic_horizontal_details( [ [ `E`, `-`, `mail`, q0n(anything), `:`, read_ahead( [ q0n(word), `@` ] ) ]
																				, buyer_email, s1, tab ] )
																				
	, check( buyer_email = Email )
	
	, delivery_email( Email )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [ 
%=======================================================================

	  q(0,5,line), delivery_header_line
	  
	, check( hook(start) = Start )
	
	, check( sys_calculate( Left, Start - 10 ) )
	  
	, delivery_thing( 1, Left, -300, [ delivery_party ] )
	
	, delivery_thing( 1, Left, -300, [ delivery_street ] )
	
	, delivery_city_and_postcode_line( 1, Left, -300 )
	
	, delivery_location_line( 1, Left, -300 )
	  
] ).


%=======================================================================
i_line_rule( delivery_location_line, [ generic_item( [ delivery_location, w, none ] ) ] ).
%=======================================================================
i_line_rule( delivery_header_line, [ read_ahead( [ `Indirizzo`, `consegna` ] ), hook(w)] ).
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

	  delivery_postcode( f( [ q(any,0,20), begin, q(dec,5,5), end ] ) )
	  
	, delivery_city(s1)
	
	, trace( [ `delivery stuffs`, delivery_city, delivery_postcode ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [ qn0(line), get_totals_header_line, q(0,3,line), get_totals_line ] ).
%=======================================================================
i_line_rule( get_totals_header_line, [ qn0(anything), tab, `Totale`, tab, `EUR` ] ).
%=======================================================================
i_line_rule( get_totals_line, [ 
%=======================================================================

	  q10( [ qn0(anything), tab ] )
	  
	, read_ahead( [ generic_item( [ total_net, d, newline] ) ] )
	
	, generic_item( [ total_invoice, d, newline ] )
	
	, check( total_net(start) > 300 )
	  
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
		
			  line_invoice_line
			  
			, line_continuation_line

			, line

		] )

	] )
		
	, line_end_line

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `Pos`, `.`, q01(tab), `Articolo` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ qn0(anything), `Totale` ] ).
%=======================================================================
i_line_rule_cut( line_continuation_line, [ retab( [ -150 ] ), append( line_descr(s1), ``, ` ` ), tab, newline ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_order_line_number, d, tab ] )
		  
	, generic_item( [ line_item_for_buyer, s1, tab ] )
	
	, q01( generic_item( [ rev, d, tab ] ) )
	
	, generic_item( [ line_quantity_uom_code, s1, tab ] )

	, generic_item( [ line_quantity, d, tab ] )

	, generic_item( [ line_unit_amount, d, `q10`, tab ] )
	
	, q01( generic_item( [ sconti, s1, tab ] ) )

	, generic_item( [ line_net_amount, d, tab ] )

	, generic_item( [ line_original_order_date, date, newline ] )
	
	, line_descr( `` )

] ).
