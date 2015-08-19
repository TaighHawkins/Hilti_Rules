%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - FCO SERVICES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( fco_services, `16 April 2015` ).

i_date_format( _ ).

i_pdf_paramater( x_tolerance_100, 100 ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).
i_user_field( invoice, delivery_district, `Delivery District` ).
i_user_field( invoice, type_of_supply, `Type of Supply` ).

i_orders05_idocs_e1edkt1( `Z011`, picking_instructions ).
i_user_field( invoice, picking_instructions, `Picking Instructions` ).
i_orders05_idocs_e1edkt1( `Z012`, packing_instructions ).
i_user_field( invoice, packing_instructions, `Packing Instructions` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, gen_capture( [ [ `Order`, `Number`, `:`,tab ], order_number, s1, newline ] )
	, gen_capture( [ [ `Order`, `Date`, `:`, tab ], invoice_date, date, newline ] )
	
	, gen_capture( [ [ `Buyer`, `:` ], buyer_contact, s1, or( [ newline, tab ] ) ] )

	, get_invoice_type
	
	, get_buyer_contact_and_email

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

%%%%%%%%%%%%%%%%%%
	  buyer_party( `LS` )

	, supplier_party( `LS` )

	, buyer_registration_number( `GB-FCO` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
%%%%%%%%%%%%%%%%%%
	
	, sender_name( `FCO Services` )
	
	, delivery_party( `FCO SERVICES - (CSCG)` )
	, delivery_note_number( `12292021` )
	
	, suppliers_code_for_buyer( `12292021` )
	
	, buyer_ddi( `01908 515 680` )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT AND EMAIL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact_and_email, [
%=======================================================================

	  buyer_email(From), trace( [ `buyer_email`, buyer_email ] )
	
] )
:-
	i_mail( from, From ), string_to_lower( From, FromL ), not( q_sys_sub_string( FromL, _, _, `@hilti.com` ) )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT AND EMAIL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_type, [ 
%=======================================================================

	gen_capture( [ [ `Amendment`, `:` ], invoice_type_dummy, s1, newline ] )
	
	, check( invoice_type_dummy \= `0` ), invoice_type(`ZE`) 
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	q0n(line)
	  
	, generic_horizontal_details( [ [ `Order`, `Total`, tab, `GBP`, tab ], total_net, d, newline ] )

	, check( total_net = Net )
	, total_invoice( Net )
	
	, or( [
	
		[ with( invoice, delivery_charge, Charge )
			, check( sys_calculate_str_subtract( total_net, Charge, Net_1 ) )		
			, net_subtotal_2( Charge )		
			, gross_subtotal_2( Charge )
			
		]
		
		, [ without( delivery_charge )	
			, check( total_net = Net_1 )		
		]
		
	] )
	
	, net_subtotal_1( Net_1 )
	, gross_subtotal_1( Net_1 )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	line_header_line
	  
	, trace([`here`])

	, q0n( or( [ line_invoice_rule, line ] ) )

	, line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ 
%=======================================================================

	q0n(anything), `Supplier`, `Item`, `Code`, tab, read_ahead(`Description`), header(w), `of`
	
] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or( [ 
	
		[ `Order`, `Total` ] 
		
		, [ dummy, check( dummy(page) \= header(page) ) ]
		
	] )
	
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line

	, q10( [ check( i_user_check( check_for_delivery, line_descr ) )

		, line_type( `ignore` )
		, check( line_net_amount = Net )
		, delivery_charge( Net )
	
	] )

	
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	generic_no( [ line_order_line_number, d, tab ] )
	
	, or( [
	
		[ line_descr(s), q10(tab), line_item( f( [ begin, q(dec,4,10), end ] ) ) ]
		
		, [ line_descr(s), line_item(`Missing`) ]
		
	] ), tab
		
	, trace( [ `Line Item`, line_item ] )
	
	, generic_item( [ line_original_order_date, date, tab ] )
	
	, generic_no( [ line_quantity, d, q10(tab) ] )

	, generic_item( [ line_quantity_uom_code, s1, tab ] )
	
	, generic_no( [ line_unit_amount, d, tab ] )
	
	, generic_no( [ line_net_amount, d, newline ] )

] ).

%=======================================================================
i_user_check( check_for_delivery, Delivery ):-
%=======================================================================

	  string_to_lower( Delivery, Delivery_L )
	, string_string_replace( Delivery_L, `/`, ` / `, Delivery_Rep )
	, sys_string_split( Delivery_Rep, ` `, Delivery_Words )
	, q_sys_member( Delivery_Word, Delivery_Words )
	, q_sys_member( Delivery_Word, [ `delivery`, `deliver`, `freight`, `carriage`, `haulage`, `transport` ] )
	, trace( `delivery line, line being ignored` )
.