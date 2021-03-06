%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - MORAND
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( morand, `14 July 2015` ).

i_date_format( _ ).

i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
% I USER FIELDS
%=======================================================================

i_user_field( line, potential_quantity, `potential quantity` ).
i_user_field( line, box_quantity, `box quantity` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	
	, get_delivery_address

	, get_buyer_contact
	
	, get_order_number
	
	, get_order_date
	
	, get_due_date
	
	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

	, get_totals

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STATIC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [ 
%=======================================================================

	  buyer_party( `LS` )

	, supplier_party( `LS` )

	, buyer_registration_number( `CH-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10402444` ) ]    %TEST
	    , suppliers_code_for_buyer( `10481332` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`2100`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [ 
%=======================================================================

	  q0n(line), delivery_header_line( [ LEFT ] )
	  
	, q10( delivery_street_line( 1, LEFT, 500 ) )
	  
	, delivery_city_state_postcode_line( 1, LEFT, 500 )
	  
] ).

%=======================================================================
i_line_rule( delivery_header_line( [ LEFT ] ), [ 
%=======================================================================

	  `Lieu`, `de`, `livraison`, hook(w), tab
	  
	, delivery_party(s1), tab
	
	, check( i_user_check( gen_same, hook(end), LEFT ) )
	
] ).

%=======================================================================
i_line_rule( delivery_street_line, [ 
%=======================================================================

	  delivery_street(s1), gen_eof
	
	, trace( [ `delivery street`, delivery_street ] )
	
] ).

%=======================================================================
i_line_rule( delivery_city_state_postcode_line, [ 
%=======================================================================
	
	  delivery_postcode(f( [ begin, q(dec,4,5), end ] ) ), tab
	  
	, delivery_city(s1), gen_eof
	
	, trace( [ `other delivery stuffs`, delivery_postcode, delivery_city ] )
	  
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER INFO * DATES * CONTACT DETAILS * TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,5,line), generic_horizontal_details( [ [ `COMMANDE`, `FOURNISSEUR` ], order_number, s1, newline ] )
	  
] ).

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  q(0,15,line), generic_horizontal_details( [ [ `Acheteur` ], buyer_contact, s1, tab ] )
	  
	, generic_horizontal_details( [ `nothin`, buyer_email, s1, tab ] )
	
	, check( buyer_email(end) < 0 )
	
	, generic_horizontal_details( [ `nothin`, buyer_ddi, s1, tab ] )
	
	, check( i_user_check( gen_same, buyer_contact, CON ) )
	
	, delivery_contact( CON )
	
	, check( i_user_check( gen_same, buyer_email, EM ) )
	
	, delivery_email( EM )
		
	, check( i_user_check( gen_same, buyer_ddi, DDI ) )
	
	, delivery_ddi( DDI )	
	 
] ).

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	  q(0,5,line), generic_horizontal_details( [ [ `La`, `Tour`, `-`, `de`, `-`, word, `,`, `le` ], invoice_date, date, gen_eof ] )
	  
] ).

%=======================================================================
i_rule( get_due_date, [ 
%=======================================================================

	  q(0,20,line), generic_horizontal_details( [ [ `Delai`, `de`, `livraison`, `:` ], due_date, date, gen_eof ] )
	  
] ).

%=======================================================================
i_rule( get_totals, [ q0n(line), totals_line ] ).
%=======================================================================
i_line_rule( totals_line, [
%=======================================================================

	  q0n(anything), `Total`, `CHF`, `HT`, tab
	  
	, read_ahead( total_net( fd( [ begin, q([dec,other_skip("'")],1,10), q(other("."),1,1), q(dec,2,2), end ] ) ) )
	  
	, total_invoice( fd( [ begin, q([dec,other_skip("'")],1,10), q(other("."),1,1), q(dec,2,2), end ] ) ), newline
	
	, trace( [ `total invoice`, total_invoice ] )
	  
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

	, qn0( [ peek_fails(line_end_line)

		, or( [  line_invoice_line
			
				, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `N`, `°`, tab, `Désignation`, tab, `Quantité` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ or( [ [ `Total`, `CHF`, `HT` ], [ `Page`, dum(d) ] ] ) ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================
   
	  generic_item( [ line_item, s1, tab ] )
	
	, generic_item( [ line_descr, s1, tab ] )
	
	, line_quantity( fd( [ begin, q([dec,other_skip("'")],1,10), end ] ) )
	
	, generic_item( [ line_quantity_uom_code, w, tab ] )
	
	, generic_item( [ line_unit_amount_x, w, tab ] )
	
	, generic_item( [ line_dec_perc, d, tab ] )
	
	, line_net_amount( fd( [ begin, q([dec,other_skip("'")],1,10), q(other("."),1,1), q(dec,2,2), end ] ) ) , newline
	
	, trace( [ `line net amount`, line_net_amount ] )
	
	, q10( [ with( invoice, due_date, DATE )
	
		, line_original_order_date( DATE )
		
		, trace( [ `line_original_order_date`, line_original_order_date ] )
	] )
	
	, count_rule
	
] ).

%=======================================================================
i_rule( count_rule, [
%=======================================================================
   
	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	
	, line_order_line_number(NEXT_LINE_NUMBER)
	
] ).