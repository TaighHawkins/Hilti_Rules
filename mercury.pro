%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - MERCURY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( mercury, `28 July 2015` ).

i_date_format( _ ).

i_user_field( invoice, street_two, `street two storage` ).

i_user_field( invoice, due_date_year, `due date year storage` ).
i_user_field( invoice, final_page, `Final Page` ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	  
	, [ q(0,10,line), get_invoice_type ]
	  
%	, get_delivery_party
	
%	, get_delivery_address

	, get_delivery_location

	, get_buyer_contact
	
	, get_buyer_ddi
	
	, get_buyer_fax
	
	, get_buyer_email

	, get_order_number

	, get_order_date
	
	, get_due_date

	, get_totals
	
	, get_totals_ze
	
	, get_invoice_lines


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

%	, buyer_registration_number( `shipping` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `IE-MERCURY` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4600`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10576456` ) ]    %TEST
	    , suppliers_code_for_buyer( `12211521` )                      %PROD
	]) ]
	
	, delivery_party( `MERCURY ENGINEERING LIMITED` )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TYPE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_invoice_type, [ 
%=======================================================================

	`AMENDED`, `PURCHASE`, `ORDER`

	, invoice_type(`ZE`)
	
	, set( ze )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER * BUYER INFO * DATES * DELIVERY LOCATION * TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,15,line), horizontal_details_line( [ [ `Purchase`, `Order`, `No` ], order_number, s1, newline ] )
	  
] ).

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  q(0,15,line), horizontal_details_line( [ [ `Buyer` ], 150, buyer_contact, s1, newline ] )
	  
] ).

%=======================================================================
i_rule( get_buyer_ddi, [ 
%=======================================================================

	  q(0,5,line), horizontal_details_line( [ [ `Phone` ], buyer_ddi, s1, newline ] )
	  
] ).

%=======================================================================
i_rule( get_buyer_email, [ 
%=======================================================================

	  q(0,7,line), horizontal_details_line( [ [ `E`, `-`, `Mail` ], buyer_email, s1, newline ] )
	  
] ).

%=======================================================================
i_rule( get_buyer_fax, [ 
%=======================================================================

	  q(0,5,line), horizontal_details_line( [ [ `Fax` ],  buyer_fax, s1, newline ] )
	  
] ).

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	  q(0,15,line), horizontal_details_line( [ [ `Date` ], 150, invoice_date, date, newline ] )
	  
] ).

%=======================================================================
i_rule( get_due_date, [ 
%=======================================================================

	  q(0,20,line), horizontal_details_line( [ [ `Delivery`, `Date` ], 150, due_date, date, newline ] )
	  
] ).

%=======================================================================
i_rule( get_delivery_location, [ 
%=======================================================================

	  q(0,15,line), read_ahead( horizontal_details_line( [ [ `Job`, `Ref` ], 150, delivery_location, s1, newline ] ) )
	  
	, horizontal_details_line( [ [ `Job`, `Ref` ], 150, customer_comments, s1, newline ] ) 
	
] ).

%=======================================================================
i_rule( get_totals, [ 
%=======================================================================

	  q0n(line), read_ahead( horizontal_details_line( [ [ `Subtotal`, `excl`, `.`, `VAT` ], 200, total_net, d, newline ] ) )
	  
	, horizontal_details_line( [ [ `Subtotal`, `excl`, `.`, `VAT` ], 150, total_invoice, d, newline ] )
	
	, q0n(line), generic_horizontal_details( [ `Page`, final_page, d ] )

] ).

%=======================================================================
i_rule( get_totals_ze, [ 
%=======================================================================

	  test( ze ), without( total_net )
	  
	, q0n(line), ze_totals_line
	  
] ).

%=======================================================================
i_line_rule( ze_totals_line, [ 
%=======================================================================

	  `New`, `Value`, `:`, tab
	  
	, read_ahead( [ total_net(d), `EUR` ] )
	
	, total_invoice(d), `EUR`
	
	, trace( [ `totals`, total_net, total_invoice ] )
	  
] ).


%=======================================================================
i_line_rule( horizontal_details_line( [ SEARCH, VARIABLE, PARAMETER, AFTER ] ), [ horizontal_details( [ SEARCH, 100, VARIABLE, PARAMETER, AFTER ] ) ] ).
%=======================================================================
i_line_rule( horizontal_details_line( [ SEARCH, TAB_LENGTH, VARIABLE, PARAMETER, AFTER ] ), [ horizontal_details( [ SEARCH, TAB_LENGTH, VARIABLE, PARAMETER, AFTER ] ) ] ).
%=======================================================================

%=======================================================================
i_rule( horizontal_details( [ SEARCH, TAB_LENGTH, VARIABLE, PARAMETER, AFTER ] ), [
%=======================================================================

	  q0n(anything)
	
	, SEARCH
	  
	, q10( or( [ `:`, `-`, `;`, `.` ] ) )
	
	, q10( tab( TAB_LENGTH ) )
	  
	, READ_VARIABLE
	
	, or( [ check( q_sys_member( AFTER_STRING, [ `none` ] ) )
	
			, AFTER
			
		] )
	
	, trace( [ VARIABLE_NAME, VARIABLE ] )

] )
:-

	  READ_VARIABLE=.. [ VARIABLE, PARAMETER ]
	
	, sys_string_atom( VARIABLE_NAME, VARIABLE )
	
	, sys_string_atom( AFTER_STRING, AFTER )
	
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_party, [
%=======================================================================

	q01(line), delivery_party_line
	
] ).


%=======================================================================
i_line_rule_cut( delivery_party_line, [
%=======================================================================

	  delivery_party(s1), tab
	  
	, check( delivery_party(end) < 0 )
	  
	, trace( [ `delivery party`, delivery_party ] )

] ).


%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================

	  q0n(line), delivery_start_header

	, delivery_street_two_line
	
	, q10( fao_line )
	
	, delivery_street_line
	
	, delivery_city_line
	
	, check( i_user_check( gen_same, street_two, TWO ) )
	
	, delivery_street( TWO )
	
] ).

%=======================================================================
i_line_rule_cut( delivery_start_header, [
%=======================================================================

	 `Delivery`, `Address`,  tab

	, trace( [`delivery start header found`] )

] ).

%=======================================================================
i_line_rule_cut( delivery_street_two_line, [
%=======================================================================

	  street_two(s1), gen_eof
	 
	, check( street_two(end) < 0 )
	
	, trace( [ `street two`, street_two ] )

] ).

%=======================================================================
i_line_rule_cut( fao_line, [
%=======================================================================

	  `FAO`
	
	, trace( [ `FAO line` ] )

] ).

%=======================================================================
i_line_rule_cut( delivery_street_line, [
%=======================================================================

	  delivery_street(s1)
	  
	, check( delivery_street(end) < 0 )
	
	, trace( [ `delivery street`, delivery_street ] )

] ).

%=======================================================================
i_line_rule_cut( delivery_city_line, [
%=======================================================================

	  delivery_city(s1)
	  
	, check( delivery_city(end) < 0 )
	
	, trace( [ `delivery city`, delivery_city ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	 line_header_line
	 
	, peek_ahead( line_page_check_line )

	, qn0( [ peek_fails(line_end_line)

		, or([ line_invoice_rule_hilti

			, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `item`, tab, `Material`, `/`, `Description` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================

	  or( [ [ `Subtotal`, `excl`, `.`, `VAT` ]
	  
			, [ `STANDARD`, `CONDITIONS`, `OF`, `PURCHASE` ]
			
			, [ `Net`, `Price`, `Changed` ]
			
		] )
	  
] ).

%=======================================================================
i_rule_cut( line_invoice_rule_hilti, [
%=======================================================================

	  line_invoice_line
	  
	, or( [ hilti_number_and_description_line
	
		, [ line_descr_line
	
			, q10( vendor_item_line )
			
		]
		
	] )

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_order_line_number, d, tab ] )
	  
	, generic_item( [ line_item_for_buyer, s1, tab ] )
	
	, generic_item( [ line_quantity, d, tab ] )
	
	, generic_item( [ line_quantity_uom_code, s1, tab ] )
	
	, generic_item( [ line_unit_amount, d, tab ] )
	
	, generic_item( [ line_net_amount, d, newline ] )

	, or( [ [ with( invoice, due_date, DATE )

				, line_original_order_date( DATE )
				
			]
			
			, test( ze )
			
		] )

] ).

%=======================================================================
i_line_rule_cut( hilti_number_and_description_line, [
%=======================================================================

	  read_ahead( [ q0n(word), line_item(f( [ begin, q(dec,5,10), end ] ) ) ] )
	  
	, trace( [ `line item`, line_item ] )
	
	, generic_item( [ line_descr, s1, newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_descr_line, [
%=======================================================================

	   generic_item( [ line_descr, s1, newline ] )

] ).

%=======================================================================
i_line_rule_cut( vendor_item_line, [
%=======================================================================

	  q0n(word), `Vendor`
	   
	, q0n(word),  line_item(f( [ begin, q(dec,5,10), end ] ) )
	
	, trace( [ `line item`, line_item ] )

] ).


%=======================================================================
i_line_rule_cut( line_page_check_line, [
%=======================================================================

	  dummy(s1)
	, with( invoice, final_page, Page )
	, check( sys_string_number( Page, PageNo ) )
	
	, check( dummy(page) =< PageNo )

] ).