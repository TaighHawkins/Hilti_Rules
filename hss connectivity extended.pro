%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - HSS CONNECTIVITY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( hss_connectivity, `15 January 2015` ).


i_pdf_parameter( no_scaling, 1 ).
i_pdf_parameter( max_pages, 10 ).

i_date_format( _ ).

i_user_field( line, zzf_contract_type, `ZZF contract type` ).
i_user_field( line, zzf_minv_nr, `ZZF inv nr` ).
i_user_field( line, zzf_morg_ref, `ZZF morg ref` ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%	---	09/07/2014
%
%	-	Adjusted the method of finding the orders in the page split
%	-	Page split analyses pages individually - if the order got too long
%		there was no header line to analyse - resulting in missed orders
%
%	-	Using the position of the location number now - first value after
%		a tab, number, tab
%
%	---	08/01/2015
%
%	-	Massive revamp - communicates between pages for accurate counting of orders
%		-	Currently works for two pages - unsure on the mechanism for three
%		-	Doesn't work for more than three - the junk rule will deal with it for now
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_default( continuation_page ).
%=======================================================================
i_page_split_rule_list( [ count_orders ] ).
%=======================================================================
i_rule( count_orders, [ 
%=======================================================================

	check( i_user_check( gen_cntr_set, 20, 0 ) )
	
%	Note - this will only work for two pages - untested for three	
	, last_order_from_previous_page_rule
	
	, q01(line)
	
	, or( [ get_delivery_hook, peek_ahead( tool_line ) ] )
	
	, qn0(
		or( [
			[ order_line, check( i_user_check( gen_cntr_inc_str, 20, Value ) ) ]
			
			, line
		] )
		
	), check( i_user_check( gen_cntr_get, 20, Orders ) )
	
	, continuation_page( Orders )
	
	, trace( [ `Number of orders`, Orders ] )
	
	, q10( [ test( order_location, OL )
		, check( set_imail_data( `final_order_on_page`, OL ) )
	] )
	
] ).

%=======================================================================
i_rule_cut( last_order_from_previous_page_rule, [ set( order_location, OL ) ] ):- q_imail_data( self, `final_order_on_page`, OL ).
%=======================================================================
i_line_rule_cut( order_line, [ 
%=======================================================================

	  get_to_location
	  
	, new_order_location(s1)

	, check(  OL = new_order_location )

	, peek_fails( test( order_location, OL ) )

	, set( order_location, OL )
	
	, trace( [ `found a new order`, OL ] )
	
] ).

%=======================================================================
i_rule_cut( get_from_imail_rule, [ set( order_hook, Start ) ] ):- q_imail_data( self, `hook`, StartS ), sys_string_number( StartS, Start ).
%=======================================================================
i_rule_cut( get_to_location, [ 
%=======================================================================

	xor( [ test( order_hook, Start )

		, [ get_from_imail_rule, trace( [ `Got from imail` ] ), test( order_hook, Start ) ]
	
	] )
	
	, nearest( Start, 10, 50 )
	
	, dummy(d), q10( tab )
	
] ).

%=======================================================================
i_line_rule_cut( get_delivery_hook, [ 
%=======================================================================

	q0n(anything), read_ahead([ `hss`, `ecode` ]), generic_item( [ hss_hook, w ] )
	
	, q0n(anything), read_ahead( [ `Font` ] ), generic_item( [ font_hook, w ] )

	, q0n(anything), read_ahead([ `tool`, `type` ]), generic_item( [ tool_hook, w ] )

	, q0n(anything), read_ahead([ `hss`, or( [ `po`, `PONumber` ] ) ]), generic_item( [ order_hook, w ] )

	, q0n(anything), read_ahead([ `delivery`, q10( tab ), `location` ]), generic_item( [ delivery_hook, w ] )

	, set( order_location, `` )
	
	, check( order_hook(start) = Start )
	, trace( [ `Start`, Start ] )

	, check( set_imail_data( `hook`, Start ) )
	, set( order_hook, Start )
	, trace( [ `Imail set` ] )

] ).


%=======================================================================
i_line_rule_cut( tool_line, [ `hss`, `fm`, `tool` ]).
%=======================================================================



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	  
	, get_the_date

	, or( [ get_the_order, [ set(chain,`junk`), trace( [ `Junking, couldn't 'get_the_order'` ] ) ] ] )
	
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
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET THE DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_the_date, [ 
%=======================================================================

	  invoice_date( Today_String ), delivery_date( Today_String)
	 
	, trace( [ `invoice date`, invoice_date ] )
	
] ):-

	date_get( today, Today )
	
	, date_string( Today, `d/m/y`, Today_String )
.


%=======================================================================
i_line_rule( delivery_date_line, [ 
%=======================================================================

	  q0n(anything)

	, tab, delivery_date(date)
	 
	, trace( [ `delivery date`, delivery_date ] )
	
] ).
	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET THE ORDER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_the_order, [ 
%=======================================================================

	  q01(line), get_delivery_hook
	  
	, trace( [ `Got hook` ] )
	  
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

	, check( i_user_check( gen_cntr_set, 19, 0 ) )

	, up, qn1( line_order_line )
	
] ):-
	i_mail( sub_document_count, Skip )
.


%=======================================================================
i_rule_cut( find_correct_order, [ 
%=======================================================================

	  q0n(line)

	, order_line
	
] ).


%=======================================================================
i_rule_cut( get_line_description, [ 
%=======================================================================

	zzf_morg_ref(s), check( zzf_morg_ref(end) < hss_hook(start) )

	, nearest( hss_hook(start),0,15 ), zzf_minv_nr(s), check( zzf_minv_nr(end) < font_hook(start) )

	, nearest( tool_hook(start),30,30 ), generic_item( [ line_descr, s1, tab ] )
	  
	, nearest( order_hook(start),30,50 ), generic_item( [ order_number, s, [ q10(tab), check( order_number(end) < delivery_hook(start) ) ] ] )
	
	, generic_item( [ shipping_instructions, s1, tab ] )
	
] ).



%=======================================================================
i_line_rule_cut( line_order_line, [ 
%=======================================================================

 	get_line_description
	
	, test( order_location, OLOC ), check( shipping_instructions = OLOC )
	
	, generic_item( [ location_x, s1, tab ] )
	
	, xor( [ [ check( q_sys_sub_string( location_x, 1, _, `T` ) )
			, check( location_x = Loc )
		]
	
		, check( string_pad_left( location_x, 10, `8`, Loc ) )
		
	] )
	
	, delivery_location( Loc )
	
	, generic_item( [ line_item_for_buyer, s1, tab ] )
	
	, or( [ generic_item( [ line_quantity, d, newline ] )
	
		, [ generic_item( [ line_quantity, d, q10( tab ) ] )
		
			, generic_item( [ line_original_order_date, date ] )
			
		]
		
	] )

	, check( i_user_check( gen_cntr_get, 19, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 19, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)
	
	, line_quantity_uom_code( `EA` )
	, zzf_contract_type( `ZFP` )

] ).


i_op_param( xml_empty_tags( `ZZFMCONTRACTTYPE` ), _, _, _, _, Answer )
:-
	  line_lid_being_written( LID )
	, result( _, LID, zzf_contract_type, Answer )
.

i_op_param( xml_empty_tags( `ZZFMINVNR` ), _, _, _, _, Answer )
:-
	  line_lid_being_written( LID )
	, result( _, LID, zzf_minv_nr, Answer )
.

i_op_param( xml_empty_tags( `ZZFMORGREF` ), _, _, _, _, Answer )
:-
	  line_lid_being_written( LID )
	, result( _, LID, zzf_morg_ref, Answer )
.

