%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - DE RUHRVERBAND
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( de_ruhrverband, `10 February 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number
	
	, get_order_date

	, get_due_date
	
	, get_delivery_details

	, get_contacts

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
	  [ test(test_flag), suppliers_code_for_buyer( `10177600` ) ]    %TEST
	    , suppliers_code_for_buyer( `10295627` )                      %PROD
	]) ]

	, customer_comments( `Lieferanten-Nr.: 703044` )
	
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
	  
	  q(0,10,line), generic_vertical_details( [ [ `Bestellnummer` ], `Bestellnummer`, order_number, s1, newline ] )
	
] ).


%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	  qn0(line), generic_horizontal_details( [ `den`, invoice_date, date ] )
	  
] ).

%=======================================================================
i_rule( get_due_date, [ 
%=======================================================================

	  q(0,20,line),generic_horizontal_details( [ `Liefertermin` ] )
	  
	, generic_horizontal_details( [ due_date, date, newline ] )
	  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACT DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_contacts, [ 
%=======================================================================

	  q(0,15,line), generic_vertical_details( [ [ `Ansprechpartner`, `/`, `in`, `:` ], `in`, things, s1, tab ] )
	  
	, check( i_user_check( get_contact, things, Dept ) )
	
	, buyer_dept( Dept )
	
	, delivery_from_contact( Dept )

] ).

%=======================================================================
i_user_check( get_contact, String_In, Dept )
%-----------------------------------------------------------------------
:-
%=======================================================================

	sys_string_split( String_In, ` `, Thing_list ),
	sys_reverse( Thing_list, [ Sur_l2 | _ ] ),
	
	( sys_string_split( Sur_l2, `,`, [ Sur_l | _ ] ) 
	
		;	Sur_l = Sur_l2 	
	),
	
	string_to_upper( Sur_l,  Sur ),
	sys_string_length( Sur, Sur_Len ),
	
	( Sur_Len =< 10
		->	Sur_Final = Sur 
			
		;	Sur_Len > 10, 
			q_sys_sub_string( Sur, 1, 10, Sur_Final ) 
	),
	
	strcat_list( [ `DERUHR`, Sur_Final ], Dept ) 
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( delivery_header_line, [ read_ahead( `Liefer` ), hook(w), `-`, `/`, `Ausführungsort:` ] ).
%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================
	  
	  q(0,15,line), delivery_header_line
	  
	, delivery_thing( [ delivery_party ] )
	
	, delivery_thing( [ delivery_dept ] )
	
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
	
	, generic_item( [ delivery_city, s1, newline ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ `Netto`, `-`, `Auftragssumme`, `in`, `EUR` ], 400, total_invoice, d, newline ] )
	  
	, check( total_invoice = Net )
	
	, total_net( Net )

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

	, q0n( [

		  or( [ 
		
			  line_invoice_rule

			, line

		] )

	] )
		
	, line_end_line

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `Pos`, `.`, tab, `Menge` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `Netto`, `-`, `Auftragssumme` ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	  
	, or( [ line_item_line, line_item( `Missing` ) ] )
	
	, with( invoice, due_date, Due )
	
	, line_original_order_date( Due )

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_order_line_number, d, tab ] )

	, generic_item( [ line_quantity, d, q10( tab ) ] )
	
	, generic_item( [ line_quantity_uom_code, w, tab ] )
	
	, generic_item( [ line_item_for_buyer, w, q10( tab ) ] )

	, generic_item( [ line_descr, s1, tab ] )

	, generic_item( [ line_unit_amount_x, d, [ q10( [ `/`, num(d) ] ), tab ] ] )
	
	, generic_item( [ line_net_amount, d, newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

	  `Ihre`, `Materialnummer`
	  
	, generic_item( [ line_item, [ begin, q(dec,4,10), end ] ] )

] ).