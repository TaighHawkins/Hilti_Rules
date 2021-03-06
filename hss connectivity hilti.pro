%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - HSS CONNECTIVITY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( hss_connectivity, `13 May 2014` ).

i_date_format( _ ).

i_user_field( line, zzf_contract_type, `ZZF contract type` ).

i_default( continuation_page ).
%=======================================================================
i_page_split_rule_list( [ count_orders ] ).
%=======================================================================
i_rule( count_orders, [ 
%=======================================================================

	check( i_user_check( gen_cntr_set, 20, 0 ) )
	
	, qn0(
		or( [
			[ order_line, check( i_user_check( gen_cntr_inc_str, 20, Value ) ) ]
			
			, line
		] )
		
	), check( i_user_check( gen_cntr_get, 20, Orders ) )
	
	, continuation_page( Orders )
	
	, trace( [ `Number of orders`, Orders ] )
	
] ).

%=======================================================================
i_line_rule_cut( order_line, [ 
%=======================================================================

	  generic_item( [ dummy, s1, tab ] )
	
	, the_order( f( [ q(dec,5,15) ] ) ), q01( tab )
	
	, location( f( [ q(alpha,3,25) ] ) ), tab
	
	, loc_num( f( [ q(dec,2,10) ] ) ), tab
	
	, trace( [ `found an order line` ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	  
	, get_the_date

	, get_the_order
	
	, total_net( `0` )
	
	, total_invoice( `0` )

	, [ with( _, line_original_order_date, DD), delivery_date(DD) ]

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

	, buyer_registration_number( `GB-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, type_of_supply( `S1` )
	
     , [ or([ 
       [ test(test_flag), suppliers_code_for_buyer( `10579629` ) ]    %TEST
         , suppliers_code_for_buyer( `12263778` )                      %PROD
     ]) ]
	
	, buyer_contact( `PAUL SALMON` )
	
	, buyer_ddi( `01618884808` )
	
	, buyer_email( `psalmon@hss.com` )
	
	, zzf_contract_type( `ZFP` )

	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET THE DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_the_date, [ 
%=======================================================================

	  invoice_date( Today_String )
	 
	, trace( [ `invoice date`, invoice_date ] )
	
] ):-

	date_get( today, Today )
	
	, date_string( Today, `d/m/y`, Today_String )
.

	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET THE ORDER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_the_order, [ 
%=======================================================================

	  get_to_the_header
	  
	, q10( point_line )
	
	, q10( number_line )
	
	, get_order_rule
	
	, line_net_amount( `0` )
	
] ).

%=======================================================================
i_rule_cut( get_to_the_header, [ q0n(line), line_header_line ] ).
%=======================================================================
i_line_rule_cut( line_header_line, [ `Tool`, `Type`, tab ] ).
%=======================================================================
i_line_rule_cut( number_line, [ `Number` ] ).
%=======================================================================
i_line_rule_cut( point_line, [ `Point` ] ).
%=======================================================================

%=======================================================================
i_rule( get_order_rule, [ 
%=======================================================================

	  q( Skip, Skip, find_correct_order )

	, line_order_line
	
] ):-
	i_mail( sub_document_count, Skip_Plus_One )
	, sys_calculate( Skip, Skip_Plus_One - 1 )
.


%=======================================================================
i_rule_cut( find_correct_order, [ 
%=======================================================================

	  q0n(line)
	  
	, order_line
	
] ).

%=======================================================================
i_line_rule_cut( line_order_line, [ 
%=======================================================================

	  generic_item( [ line_descr, s1, tab ] )
	  
	, order_number( f( [ begin, q(dec,5,15), end ] ) ), q01( tab )
	
	, generic_item( [ shipping_instructions, s1, tab ] )
	
	, generic_item( [ location_x, s1, tab ] )
	
	, check( string_pad_left( location_x, 10, `8`, Loc ) )
	
	, delivery_location( Loc )
	
	, generic_item( [ line_item_for_buyer, s1, tab ] )
	
	, or( [ generic_item( [ line_quantity, d, newline ] )
	
		, [ generic_item( [ line_quantity, d, q10( tab ) ] )
		
			, or( [ generic_item( [ line_original_order_date, date, newline ] )
			
				, [ q10( generic_item( [ line_original_order_date, date, tab ] ) )
				
					, q(4,4, [ dummy(d), q10( tab ) ] ), dummy(d), newline
					
				]
				
			] )
			
		]
		
	] ), line_order_line_number( `10` )
	
	, line_quantity_uom_code( `EA` )
	
] ).


i_op_param( xml_empty_tags( `ZZFMCONTRACTTYPE` ), _, _, _, _, Answer )
:-
	  line_lid_being_written( LID )
	, result( _, LID, zzf_contract_type, Answer )
.
