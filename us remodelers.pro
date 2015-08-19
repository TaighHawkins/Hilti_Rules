%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - US Remodellers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( us_remodellers_rules, `2 Sept 2013` ).

%i_pdf_parameter( try_ocr, `yes` ).
%i_pdf_parameter( max_pages, 1 ).
%i_pdf_parameter( new_line, 12 ).
%i_pdf_parameter( same_line, 3).
%i_pdf_parameter( tab, 10 ).
%i_pdf_parameter( space, 2 ).

%i_pdf_parameter( no_scaling, 1 ).

i_date_format( 'mon d, y' ).

i_format_postcode( X, X ).

i_trace_lists.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule_list( [
%=======================================================================

	 set( purchase_order )

	, buyers_code_for_location(`ShipToNumber`)

	, buyer_party(`US Remodelers`)

	, currency( `USD` )

	, get_contract_order_reference

	, get_customer_comments

	, get_order_number

	, get_invoice_date

	, get_due_date

	, get_delivery_details

	, get_delivery_party

	, get_totals

	, get_po_lines
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================

	q0n(line)
	
	, order_number_header_line( [ START, END ] )

	, q0n( gen_line_nothing_here( [ START, END, 10, 10 ] ) )

	, order_number_data_line( [ START, END ] )

	, trace( [ `order_number`, order_number ] )

] ).

%=======================================================================
i_line_rule( order_number_header_line( [ START, END ] ), [
%=======================================================================

	q0n( anything )

	, peek_ahead( `Purchase` )

	, on_start_anchor(w1)

	, `Order`

	, peek_ahead( `Number` )

	, on_end_anchor(w1)

	, check( i_user_check( gen_same, on_start_anchor(start), START ) )

	, check( i_user_check( gen_same, on_end_anchor(end), END ) )
] ).

%=======================================================================
i_line_rule( order_number_data_line( [ START, END ] ), [
%=======================================================================

	nearest( [ START, END, 10, 10 ] )

	, order_number(s1)

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_contract_order_reference, [
%=======================================================================

	q0n(line)
	
	, contract_order_reference_header_line

	, contract_order_reference_data_line

	, trace( [ `contract_order_reference`, contract_order_reference ] )

] ).

%=======================================================================
i_line_rule( contract_order_reference_header_line, [ `Reference`, tab, `Contact` ] ).
%=======================================================================

%=======================================================================
i_line_rule( contract_order_reference_data_line, [ contract_order_reference(s1) ] ).
%=======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_customer_comments, [
%=======================================================================

	q0n(line)
	
	, po_header_line

	, q0n( line )

	, job_line

	, order_line

	, trace( [ `notes`, narrative ] )

] ).

%=======================================================================
i_line_rule( job_line, [ `Job`, `:`, tab, wrap( narrative(s1), `Job: `, `` ) ] ).
%=======================================================================

%=======================================================================
i_line_rule( order_line, [ `Order`, `:`, tab, wrap( narrative(s1), `Order: `, `` ) ] ).
%=======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_due_date, [
%=======================================================================

	q0n(line)
	
	, due_date_header_line( [ START, END ] )

	, q0n( gen_line_nothing_here( [ START, END, 10, 10 ] ) )

	, due_date_data_line( [ START, END ] )

	, trace( [ `due_date`, due_date ] )

] ).

%=======================================================================
i_line_rule( due_date_header_line( [ START, END ] ), [
%=======================================================================

	q0n( anything )

	, peek_ahead( `Expected` )

	, dd_start_anchor(w1)

	, peek_ahead( `Arr` )

	, dd_end_anchor(w1)

	, check( i_user_check( gen_same, dd_start_anchor(start), START ) )

	, check( i_user_check( gen_same, dd_end_anchor(end), END ) )
] ).

%=======================================================================
i_line_rule( due_date_data_line( [ START, END ] ), [
%=======================================================================

	nearest( START, END, 10, 10 )

	, due_date(date)
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_date, [
%=======================================================================

	q0n(line)
	
	, invoice_date_header_line( [ START, END ] )

	, q0n( gen_line_nothing_here( [ START, END, 10, 10 ] ) )

	, invoice_date_data_line( [ START, END ] )

	, trace( [ `invoice_date`, invoice_date ] )

] ).

%=======================================================================
i_line_rule( invoice_date_header_line( [ START, END ] ), [
%=======================================================================

	q0n( anything )

	, peek_ahead( `Date` )

	, date_anchor(w1)

	, check( i_user_check( gen_same, date_anchor(start), START ) )

	, check( i_user_check( gen_same, date_anchor(end), END ) )
] ).

%=======================================================================
i_line_rule( invoice_date_data_line( [ START, END ] ), [
%=======================================================================

	nearest( START, END, 10, 10 )

	, invoice_date(date)
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
%i_section( get_delivery_party, [ delivery_party_line ] ).
%=======================================================================
%i_line_rule( delivery_party_line, [ `Job`, `#`, delivery_party(w1), trace( [ `delivery_party`, delivery_party ] ) ] ).
%=======================================================================

%=======================================================================
i_rule( get_delivery_party, [ or([ [ test(test_flag), delivery_party(`88206`)], delivery_party(`2715648`) ]) ] ).
%=======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [
%=======================================================================

	gen1_address_details( [ delivery_margin, delivery_start_line, delivery_address_line, delivery_address_line,
					delivery_address_line, delivery_address_line, delivery_city1, delivery_state1, postcode( delivery_postcode, delivery_postcode_searcher ),
					delivery_end_line ] )

	, delivery_country_code( `US` )

	, trace( [ `Delivery`, delivery_location, delivery_address_line, delivery_city, delivery_state, delivery_postcode ] )
] ).


%=======================================================================
i_rule_cut( delivery_start_line, [
%=======================================================================

	delivery_header_line, trace([ `found address start` ])

	, or([ [ delivery_drop_line, q0n(line), delivery_drop_start_line], delivery_location_line ])

]).


%=======================================================================
i_line_rule( delivery_location_line, [ nearest(50,30,30), delivery_location(s) ]).
%=======================================================================


%=======================================================================
i_line_rule( delivery_drop_line, [ q0n(anything), `drop`, `shipments`, trace([`found drop line`]) ]).
%=======================================================================


%=======================================================================
i_line_rule( delivery_header_line, [
%=======================================================================

	q0n(anything)

	, read_ahead(delivery_margin(w))

	, `ship`, `to`, `:`

	, check( i_user_check( gen1_store_address_margin( delivery_margin ), delivery_margin(start), 30, 30) )
] ).




%=======================================================================
i_line_rule( delivery_drop_start_line, [
%=======================================================================

	q0n(anything)

	, `Drop`, `ship`, `to`, `:`

	, tab

	, read_ahead(delivery_margin)

	, delivery_location(s1)

	, check( i_user_check( gen1_store_address_margin( delivery_margin), delivery_margin(start), 30, 30 ) )


] ).


%=======================================================================
i_rule( delivery_postcode_searcher, [
%=======================================================================

	or( [ [ delivery_city(s), `,` ], delivery_city(s) ] )

	, delivery_state( f( [ begin, q(alpha,2,2), end ] ) )

	, delivery_postcode( f( [ begin, q(dec,5,5), end ] ) )

	, q10( [

		`-`

		, append( delivery_postcode( `-` ), ``, `` )

		, append( delivery_postcode( f( [ begin, q(dec,4,4), end ] ) ) )
	] )
] ).

%=======================================================================
i_line_rule( delivery_end_line, [ 
%=======================================================================

	or( [ with(delivery_postcode), `Comments`, `contact`, `phone`, `reference` ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	q0n(line)
	
	, anchored_total_line( [ `Subtotal`, total_net ] )

	, q0n(line)
	
	, anchored_total_line( [ [ `Total`, `tax` ], total_vat ] )

	, q0n(line)
	
	, anchored_total_line( [ [ `Total`, `purchase`, `order` ], total_invoice ] )
] ).

%=======================================================================
i_line_rule_cut( anchored_total_line( [ ANCHOR, NAME ] ), [
%=======================================================================

	q0n( anything )

	, ANCHOR

	, tab

	, READ

	, trace( [ ANCHOR, NAME ] )
] )

:-
	READ =.. [ NAME, d ]
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_po_lines, [
%=======================================================================

	po_header_line

	, q01( line ) % in case of wraps on the header

	, qn0( [ peek_fails(po_end_line), or([ po_line, line ]) ])

] ).

%=======================================================================
i_line_rule_cut( po_header_line, [ `Qty`, `.`, tab, `Vendor`, `Item`, tab ] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( po_end_line, [ or([ [`Job`, `:`] , [`Comments`, `:`] ]) ]).
%=======================================================================

%=======================================================================
i_line_rule_cut( po_line, [
%=======================================================================

	line_quantity(d)

	, q10([ tab, line_item(s1)])

	, tab, line_descr(s1)

	, tab, ignore(s1)

	, tab, line_unit_amount(d)

	, tab, line_quantity_uom_code(s1)

	, tab, line_net_amount(d)

	, newline	

	, trace( [ `Line`, line_quantity, line_item, line_descr, line_unit_amount, line_quantity_uom_code, line_net_amount ] )
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% XML
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% PartyInfo
%

i_op_param( xml_empty_tags( `PartyId` ), _, _, _, `88204` ) :- q_check_xml_stack( [ tag( `PartyInfo`, [ attribute( iteration, 1 ) ] ) ] ), grammar_set( test_flag ).
i_op_param( xml_empty_tags( `PartyId` ), _, _, _, `2715647` ) :- q_check_xml_stack( [ tag( `PartyInfo`, [ attribute( iteration, 1 ) ] ) ] ). 
i_op_param( xml_empty_tags( `PartyRole` ), _, _, _, `originator` ) :- q_check_xml_stack( [ tag( `PartyInfo`, [ attribute( iteration, 1 ) ] ) ] ).

i_op_param( xml_empty_tags( `PartyId` ), _, _, _, `88206` ) :- q_check_xml_stack( [ tag( `PartyInfo`, [ attribute( iteration, 2 ) ] ) ] ), grammar_set( test_flag ).
i_op_param( xml_empty_tags( `PartyId` ), _, _, _, `2715648` ) :- q_check_xml_stack( [ tag( `PartyInfo`, [ attribute( iteration, 2 ) ] ) ] ). 
i_op_param( xml_empty_tags( `PartyRole` ), _, _, _, `client` ) :- q_check_xml_stack( [ tag( `PartyInfo`, [ attribute( iteration, 2 ) ] ) ] ).

%
% ApplicationArea
%

i_op_param( xml_empty_tags( `LogicalID` ), _, _, _, `LogicalId` ) :- q_check_xml_stack( [ `Sender`, `ApplicationArea` ] ).

%
% CustomerParty
%

i_op_param( xml_empty_tags( `Name` ), _, _, _, `US Remodelers` ) :- q_check_xml_stack( [ `CustomerParty` ] ).

%
% SupplierParty
%

i_op_param( xml_empty_tags( `Name` ), _, _, _, LOC ) :- q_check_xml_stack( [ `Location`, `SupplierParty` ] ), result( _, invoice, delivery_location, LOC ).

i_op_param( xml_empty_tags( `Name` ), _, _, _, `Ferguson` ) :- q_check_xml_stack( [ `SupplierParty` ] ).

%
% DeliveryParty
%

i_op_param( xml_empty_tags( `Name` ), _, _, _, `Delivery Location Name` ) :- q_check_xml_stack( [ `Location`, `DeliveryParty` ] ).

%

i_op_param( line_quantity_uom_code, _, _, _, `upper` ).

