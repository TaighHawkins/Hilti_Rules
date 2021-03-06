%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - IT LANDI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( it_landi, `13 March 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).

i_rules_file( `d_hilti_it_postcode.pro` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_order_number
	
	, get_order_date

	, get_delivery_details
	
	, get_customer_comments

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
	    , suppliers_code_for_buyer( `13033636` )                      %PROD
	]) ]
	
	, buyer_dept( `ITLANDBARETTI` )
	
	, delivery_from_contact( `ITLANDBARETTI` )
	
	, delivery_party( `LANDI SPA` )

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
	  
	  q(0,10,line), generic_vertical_details( [ [ `Ordine`, `N`, `.` ], `Ordine`, order_number, s1, tab ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [
%=======================================================================	  
	  
	  q(0,10,line), generic_vertical_details( [ [ `Data` ], `Data`, invoice_date, date, tab ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_customer_comments, [ 
%=======================================================================

	  q(0,20,line)

%	, generic_vertical_details( [ [ `Spedizione` ], `Spedizione`, end, customer_comments, s1, gen_eof ] )

	, line_header_line, customer_comments_line
	  
	, check( customer_comments = Comments )
	
	, shipping_instructions( Comments )
	
] ).

%=======================================================================
i_line_rule_cut( customer_comments_line, [ customer_comments(s1), newline ]).
%=======================================================================


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [ 
%=======================================================================

	  q0n(line), delivery_header_line
	  
	, or( [ [ test( known_address ) ]
	
		, [ peek_fails( test( known_address ) )
		
			, delivery_thing( [ delivery_street ] )
			
			, delivery_city_and_postcode_line
			
		]
		
	] )
	  
] ).


%=======================================================================
i_line_rule( delivery_header_line, [ 
%=======================================================================

	  `Consegna`, q0n(word)
	  
	, xor( [ [ `Sede`, set( known_address )
	
			, xor( [ [ test( test_flag ), delivery_note_number( `10658906` ) ]
			
				, [ delivery_note_number( `13033636` )]
				
			] ), trace( [ `known address` ] )
			
		]
		
		, [ `Cantiere`, delivery_dept( `CANTIERE` ) ]
		
	] )
	  
] ).


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

	  or( [ [ delivery_postcode( f( [ begin, q(dec,5,5), end ] ) )
	  
			, delivery_city(s1)

		]
		
		, [ delivery_city(s1)
		
			, postcode_lookup_rule
			
		]
		
	] )
	, trace( [ `delivery stuffs`, delivery_city, delivery_postcode ] )

] ).

%=======================================================================
i_rule( postcode_lookup_rule, [
%=======================================================================	  
	 	
	  check( i_user_check( find_the_postcode, PC, delivery_city, Loc, Unknown ) )
	
	, delivery_postcode( PC )
		
] ).

%=======================================================================
i_user_check( find_the_postcode, PC, City_L, State, Unknown )
%---------------------------------------
:-
%=======================================================================

	  string_to_upper( City_L, City )
	
	,(	postcode_lookup( PC, City, State, _ )
	
		;   postcode_lookup( PC, City, _, _ )
	
		;	PC = `Missing` 
	
	)
.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [ total_net( `0` ), total_invoice( `0` ) ] ).
%=======================================================================

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
			  
			, line_check_line

			, line

		] )

	] )
		
	, line_end_line

] ).


%=======================================================================
i_line_rule_cut( line_header_line, [ `Riga`, tab, `Articolo` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ or( [ [ q0n(word), `consegna` ], [ `Vostro` ] ] ) ] ).
%=======================================================================
i_line_rule_cut( line_check_line, [ dummy(d), q10( tab ), `§`, force_result( `defect` ), force_sub_result( `missed_line` ) ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_order_line_number, d, q10( tab ) ] )

	, `§`, generic_item( [ line_item_for_buyer, s1, tab ] )

	, generic_item( [ line_descr, s1, tab ] )
	
	, q01( [ read_ahead( dum(s1) ), check( dum(end) < 70 ), append( line_descr(s1), ` `, `` ), tab ] )
	
	, generic_item( [ line_quantity_uom_code, s1, tab ] )

	, generic_item( [ line_quantity, d, tab ] )
	
	, q01( [ line_unit_amount_x(d), tab, check( line_unit_amount_x(start) > 100 ) ] )

	, generic_item( [ line_original_order_date, date, newline ] )

] ).
