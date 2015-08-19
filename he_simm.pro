%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - HE SIMM standard rules
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_version( he_simm, `24 June 2015` ).
%=======================================================================
i_trace_lists.
%=======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_user_field( line, line_call_out_amount, `maximum per line per order` ).
%=======================================================================

%=======================================================================
i_initialise_rule( check( i_user_check( gen_cntr_set, 20, 1 ) ) ).
%=======================================================================

%=======================================================================
i_final_rule( final_save ).
%=======================================================================

%=======================================================================
i_rule( final_save, [ check( i_user_check( save_cache ) ) ] ).
%=======================================================================


%=======================================================================
ii_supplier_rule([ page_complete ]).
%=======================================================================

i_rule_cut( page_complete, [

	q(0, 10, line), call_off_line

	, q0n(line), ship_to_line

	, q(0, 10, line), send_order_line

]).

%=======================================================================
i_line_rule_cut( call_off_line, [ q0n(anything), `qty`, newline, trace([ `call off line` ]) ] ).
%=======================================================================
%=======================================================================
i_line_rule_cut( ship_to_line, [ `ship`, `-`, `to`, `:`, trace([ `ship to line` ]) ] ).
%=======================================================================
%=======================================================================
i_line_rule_cut( send_order_line, [ q0n(anything), `send`, `order`, newline, trace([ `send order line` ]) ] ).
%=======================================================================



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	agent_name( `GBADAPTRIS` )

	, buyer_party( `LS` )

	, [ q0n(line), requested_delivery_date_line ]

	, [ q0n(line), invoice_date_line ]

	, supplier_party( `LS` )

	, supplier_registration_number( `P11_100` )

	, get_order_number

	, [ q0n(line), buyer_header_line, buyer_registration_number_line ]

	, [ q0n(line), type_of_supply_line ]

	, cost_centre( `` )

	, agent_code_3( `4400` )

	, agent_code_2( `01` )

	, agent_code_1( `00` )
	
	, contract_order_reference( `` )

	, delivery_state( `` )

	, buyers_code_for_location( `` )

	, [ q0n(line), suppliers_code_for_buyer_line, q0n(line), buyer_contact_line, q0n(line), buyer_ddi_line, q0n(line), buyer_email_line ]

	, buyer_fax( `` )

	, buyers_code_for_buyer( `` )

	, [ q0n(line), delivery_note_number_line, q0n(line), delivery_contact_line, q0n(line), delivery_ddi_line, q0n(line), delivery_email_line, q0n(line), delivery_party_line ]

	, delivery_fax( `` )

	, delivery_party( `` )

	, delivery_dept( `` )

	, delivery_address_line( `` )

	, delivery_address_line( `` )

	, delivery_street( `` )

	, delivery_city( `` )

	, delivery_postcode( `` )

	, delivery_location( `` )

	, get_customer_comments

	, item_section

	, check_error_in_order
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( requested_delivery_date_line, [
%=======================================================================

	`Requested`, `Delivery`, `Date`, `:` 

	, requested_delivery_date( date )
	
	, trace( [ `requested_delivery_date`, requested_delivery_date] )

	, check( i_user_check( assert_requested_delivery_date, requested_delivery_date ) )
] ).

%=======================================================================
i_user_check( assert_requested_delivery_date, Value )
%-----------------------------------------------------------------------
:- sys_asserta( i_user_data( requested_delivery_date( Value ) ) ).
%=======================================================================

%=======================================================================
i_user_check( retrieve_requested_delivery_date, Value )
%-----------------------------------------------------------------------
:- i_user_data( requested_delivery_date( Value ) ).
%=======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( invoice_date_line, [
%=======================================================================

	`Order`, `Date`, `:`, tab 

	, invoice_date( date )

	, check( invoice_date(start) < -200 )
	
	, trace( [ `invoice_date`, invoice_date] )
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( buyer_header_line, [ `Supplier`, `:` ] ).
%=======================================================================
i_line_rule_cut( buyer_registration_number_line, [ 
%=======================================================================
	
	or([ [ `GB`, `-`, `HESIMM`, buyer_registration_number(`GB-HESIMM`), invoice_type( `ZE` ) ]
		, buyer_registration_number(s1)
	])	
	, trace( [ `buyer_registration_number`, buyer_registration_number ] ) 
] ).
	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( type_of_supply_line, [
%=======================================================================

	`Requested`, `Delivery`, `Time`, `:` 

	, qn0( word )

	, q10( tab )

	, `[`

	, type_of_supply( s )

	, `]`

	, trace( [ `type_of_supply`, type_of_supply] )
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================

	or( [
		[ q0n(line), order_number_line ]
		
		, [	trace( [ `cannot proceed without order number` ] )

			, check( i_user_check( mark_error_in_order ) )
		]
	] )
] ).

%=======================================================================
i_line_rule( order_number_line, [
%=======================================================================

	`Customer`, `Order`, `No`, `:`, tab
	
	, read_ahead( order_number( s1 ) )
	
	, trace( [ `order number`, order_number ] )

	, or( [
		[ 
			dummy1(d)

			, `/`

			, dummy2(d)

			, `/`

			, dummy3(d)

			, `/`

			, dummy4(d)

			, tab

			, invoice_type( `ZE` )

			, trace( [ `invoice type set to ZE` ] )
		]

		, invoice_type( `` )
	] )

	, check( i_user_check( assert_order_number, order_number ) )
	
	, q10( [ check( order_number = `C5066/M58/27203` )
		, force_result( `failed` )
		, force_sub_result( `banned_order` )
	] )
] ).

%=======================================================================
i_user_check( assert_order_number, Value )
%-----------------------------------------------------------------------
:- sys_asserta( i_user_data( order_number( Value ) ) ).
%=======================================================================

%=======================================================================
i_user_check( mark_error_in_order )
%-----------------------------------------------------------------------
:- sys_asserta( i_user_data( error_in_order ) ).
%=======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( suppliers_code_for_buyer_line, [
%=======================================================================

	`Sold`, `-`, `to`, `Number`, `:`, tab
	
	, suppliers_code_for_buyer( s1 )
	
	, trace( [ `suppliers_code_for_buyer`, suppliers_code_for_buyer ] )
] ).

%=======================================================================
i_line_rule( buyer_contact_line, [
%=======================================================================

	`Sold`, `-`, `to`, `Contact`, `:`, tab
	
	, buyer_contact( s1 )
	
	, trace( [ `buyer_contact`, buyer_contact ] )
] ).

%=======================================================================
i_line_rule( buyer_ddi_line, [
%=======================================================================

	`Sold`, `-`, `to`, `Phone`, `:`, tab
	
	, buyer_ddi( s1 )
	
	, trace( [ `buyer_ddi`, buyer_ddi ] )
] ).

%=======================================================================
i_line_rule( buyer_email_line, [
%=======================================================================

	`Sold`, `-`, `to`, `Email`, `:`, tab
	
	, buyer_email( s1 )
	
	, trace( [ `buyer_email`, buyer_email ] )
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( delivery_note_number_line, [
%=======================================================================

	`Ship`, `-`, `to`, `Number`, `:`, tab
	
	, delivery_note_number( s1 )
	
	, trace( [ `delivery_note_number`, delivery_note_number ] )
] ).

%=======================================================================
i_line_rule( delivery_contact_line, [
%=======================================================================

	`Ship`, `-`, `to`, `Contact`, `:`, tab
	
	, delivery_contact( s1 )
	
	, trace( [ `delivery_contact`, delivery_contact ] )
] ).

%=======================================================================
i_line_rule( delivery_ddi_line, [
%=======================================================================

	`Ship`, `-`, `to`, `Phone`, `:`, tab
	
	, delivery_ddi( s1 )
	
	, trace( [ `delivery_ddi`, delivery_ddi ] )
] ).

%=======================================================================
i_line_rule( delivery_email_line, [
%=======================================================================

	`Ship`, `-`, `to`, `Email`, `:`, tab
	
	, delivery_email( s1 )
	
	, trace( [ `delivery_email`, delivery_email ] )
] ).

%=======================================================================
i_line_rule( delivery_party_line, [
%=======================================================================

	q10( [ `Ship`, `-`, `to`, `:`, q10( tab ) ] )
	
	, read_ahead(sender_name( s1 )), sending_organisation(s1)
	
	, trace( [ `sender name`, sender_name ] )
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_customer_comments, [
%=======================================================================

	q0n(line)

	, peek_ahead( delivery_note_number_line )

	, customer_comments_line( 4, -50, 500 )

	, trace( [ `customer_comments`, customer_comments ] )
] ).

%=======================================================================
i_line_rule( customer_comments_line, [ customer_comments(s1) ] ).
%=======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( item_section, [
%=======================================================================

	item_line

	, with( invoice, order_number, _ )

	, line_unit_amount( `1` ) % token, so that we can suppress zero value lines

	, trace( [ `item`, line_item, line_descr, line_quantity, line_quantity_uom_code, line_pack_size, line_call_out_amount ] )

	, line_item_for_buyer( `` )

	, q10( [
			check( i_user_check( retrieve_requested_delivery_date, DELIVERY_DATE ) )

			, line_original_order_date( DELIVERY_DATE )
	] )

	, check( i_user_check( check_call_off, line_item, line_call_out_amount, line_quantity ) )

	, check( i_user_check( gen_cntr_inc, 20, VALUE ) )

	, line_order_line_number( VALUE )
] ).

%=======================================================================
i_line_rule( item_line, [
%=======================================================================

	q0n( anything )

	, line_item( d )

	, check( line_item(start) > -110 )

	, q10(tab)

	, line_descr( s )

	, tab

	, or( [
		[ line_quantity(d), q10( tab ), line_quantity_uom_code( w ) ]
		
		, [ line_quantity( `0` ), line_quantity_uom_code( w ) ]
	] )

	, tab

	, line_pack_size(d)

	, tab

	, line_call_out_amount(d)

	, newline
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_user_check( check_call_off, Part, Max, Required )
%-----------------------------------------------------------------------
:-
%=======================================================================

	i_user_data( order_number( Order ) ),

	( lookup_cache( `he_simm_call_off_summary`, Order, Part, Max, Current_and_date )

		->	( q_sys_comp_str_eq( Required, `0` )
		
				->	true
				
				;	sys_string_split( Current_and_date, `:`, [ Current | _ ] ),
				
					sys_calculate_str_add( Current, Required, New_total ),

					( q_sys_comp_str_le( New_total, Max )

						->	sys_asserta( i_user_data( new_total( Part, Max, New_total ) ) )

						;	trace( [ Part, New_total, `exceeds`, Max ] ),
							sys_asserta( i_user_data( error_in_order ) )
					)

			)

		;	( q_sys_comp_str_le( Required, Max )

				->	sys_asserta( i_user_data( new_total( Part, Max, Required ) ) )

				;	trace( [ Part, Required, `higher on request that`, Max ] ),
					sys_asserta( i_user_data( error_in_order ) )
			)
	)
.

%=======================================================================
i_rule( check_error_in_order, [ force_result( `defect` ), force_sub_result( `Error_in_call_off` ) ] ) :- i_user_data( error_in_order ).
%=======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_user_check( save_cache )
%-----------------------------------------------------------------------
:- i_user_data( error_in_order ).
%=======================================================================

%=======================================================================
i_user_check( save_cache )
%-----------------------------------------------------------------------
:-
%=======================================================================

	date_get( today, Today ),
	
	date_string( Today, 'd/m/y', Today_string ),

	i_user_data( order_number( Order ) ),

	i_user_data( new_total( Part, Max, Required ) ),

	strcat_list( [ Required, `:`, Today_string ], Required_and_date ),

	set_cache( `he_simm_call_off_summary`, Order, Part, Max, Required_and_date ),

	trace( [ `updated`, Order, Part, Max, Required_and_date ] ),

	fail

	;

	save_cache
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% XML
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% AUTLF
%

i_op_param( xml_empty_tags( `AUTLF` ), _, _, _, `X` ) :- result( _, invoice, type_of_supply, `GF` ).
i_op_param( xml_empty_tags( `AUTLF` ), _, _, _, `X` ) :- result( _, invoice, type_of_supply, `G4` ).
i_op_param( xml_empty_tags( `AUTLF` ), _, _, _, `` ) :- result( _, invoice, type_of_supply, _ ).

