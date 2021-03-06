%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - IT SEMATIC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( it_sematic, `9 June 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number
	
	, get_order_date

	, get_delivery_details
	
	, get_buyer_contact
	
	, get_delivery_contact

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
	    , suppliers_code_for_buyer( `16056775` )                      %PROD
	]) ]

	, [ or([ 
	  [ test(test_flag), delivery_note_number( `10658906` ) ]    %TEST
	    , delivery_note_number( `20671092` )                      %PROD
	]) ]

	, set( reverse_punctuation_in_numbers )
	
	, type_of_supply( `04` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q(0,20,line), generic_vertical_details( [ [ `fornitore`, tab, `Numero` ], `Numero`, start, 5, 20, order_number, s1, tab ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [
%=======================================================================

	  q(0,20,line), generic_vertical_details( [ [ `Data`, tab, `Pagina` ], `Data`, start, invoice_date, date, tab ] )
	  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACT DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ q0n(line), buyer_contact_header, buyer_contact_line ] ).
%=======================================================================
i_line_rule( buyer_contact_header, [ `Bank`, `/`, `Banca`, tab, read_ahead( hook(w) ), `Nostro`, `Riferimento` ] ).
%=======================================================================
i_line_rule( buyer_contact_line, [
%=======================================================================

	  q10( [ dummy(s1), tab ] )
	 
	, read_ahead( [ word, buyer_contact(s1) ] )

	, append( buyer_contact(w), ` `, `` )
	
	, trace( [ `buyer contact`, buyer_contact ] )

] ).

%=======================================================================
i_rule( get_delivery_contact, [ with( invoice, buyer_contact, Con ), delivery_contact( Con ) ] ).
%=======================================================================


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
	  
	, delivery_thing( 1, Left, 500, [ delivery_party ] )
	
	, delivery_thing( 1, Left, 500, [ delivery_street ] )
	
	, delivery_city_and_postcode_line
	  
] ).

%=======================================================================
i_line_rule( delivery_header_line, [ read_ahead( [ `Indirizzo`, `di`, `consegna` ] ), hook(w)] ).
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

	  delivery_city(s), `,`
	  
	, delivery_postcode( f( [ q(any,0,20), begin, q(dec,5,5), end ] ) )
	
	, trace( [ `delivery stuffs`, delivery_city, delivery_postcode ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [ qn0(line), get_totals_line ] ).
%=======================================================================
i_line_rule( get_totals_line, [ 
%=======================================================================

	  q0n(anything), `Importo`, `totale`, tab
	  
	, read_ahead( [ generic_item( [ total_net, d, `q10`, tab ] ) ] )
	
	, generic_item( [ total_invoice, d, `q10`, tab ] )
	
	, `EUR`
	  
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
i_line_rule_cut( line_header_line, [ `to`, newline ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `ATTENDIAMO`, `VS`, `.`, `CONFERMA`, `D`, `'`, `ORDINE`] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_no( [ line_order_line_number, d, [ q10(tab), check( line_order_line_number(end) < -420 ) ] ] )

	, generic_item( [ line_item_for_buyer, sf, [ q10(tab), check( line_item_for_buyer(end) < -300 ) ] ] )

	, generic_item( [ line_descr, s, q10(tab) ] )
	
	, peek_fails( a(d) )

	, generic_item( [ line_quantity_uom_code, sf, q10(tab) ] )

	, generic_no( [ line_quantity, d, tab ] )

	, generic_no( [ line_unit_amount, d, tab ] )
	
	, generic_no( [ line_net_amount, d, tab ] )

	, read_ahead( generic_item( [ line_original_order_date, date, newline ] ) )
	
	, read_ahead( wrap( customer_comments(s1), `Consegna `, `` ) )
	
	, wrap( shipping_instructions(s1), `Consegna `, `` )

] ).

%=======================================================================
i_line_rule_cut( line_continuation_line, [
%=======================================================================

	  retab( [ -420, -300, 60  ] )
	  
	, tab
		  
	, or( [ [ append( line_item_for_buyer(s1), ``, `` ), tab ], tab ] )
	
	, or( [ [ append( line_descr(s1), ` `, `` ), tab ], tab ] )
	
	, newline

] ).