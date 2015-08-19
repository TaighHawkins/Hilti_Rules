%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - AMEON
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( ameon, `29 April 2015` ).

i_date_format( _ ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		HILTI FLEET ORDER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
%		User Fields
%=======================================================================

i_user_field( line, zzfminvnr, `ZZF minvnr` ).
i_user_field( line, zzfmorgref, `ZZF morgref` ).
i_user_field( line, zzfmcontracttype, `ZZF contracttype` ).

%=======================================================================
%		Empty Tags
%=======================================================================

i_op_param( xml_empty_tags( Fleet_U ), _, _, _, _, Answer )
:-
	  line_lid_being_written( LID )
	, fleet_thing( Fleet )
	, sys_string_atom( Fleet, Atom )
	, result( _, LID, Atom, Answer )
	, string_to_upper( Fleet, Fleet_U )
.

fleet_thing( `zzfminvnr` ).
fleet_thing( `zzfmorgref` ).
fleet_thing( `zzfmcontracttype` ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	 buyer_party( `LS` )

%	, buyer_registration_number( `Customer` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `GB-AMEON` )

	, supplier_registration_number( `P11_100` )

	, currency( `4400` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `11205766` ) ]    %TEST
	    , suppliers_code_for_buyer( `12265459` )                      %PROD
	]) ]


%	, customer_comments( `Customer Comments` )
	, or( [ [ q0n(line), customer_comments_line ] , customer_comments( `` ) ])

%	, shipping_instructions( `Shipping Instructions` )
	, shipping_instructions( `` )

	, delivery_party(`AMEON LIMITED`) 

	, get_delivery_details

	,[q0n(line), get_order_number ]

	,[q0n(line), get_order_date ]

	,[q0n(line), get_delivery_date ]
 
	,[q0n(line), get_buyer_contact ]
	
	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

	,[ q0n(line), get_net_total_number]

	,[ q0n(line), get_invoice_total_number]

	, buyer_email(`info@ameon.co.uk`)

	, buyer_ddi(`01253 760160`)
	
	, type_of_supply( `S0` )

	, [q0n(line), amended_order_line ]

] ).


%=======================================================================
i_line_rule( amended_order_line, [ 
%=======================================================================

	q0n(anything), `amended`, `order`, newline

	, delivery_note_reference(`amended_order`)

	, trace( [ `amended order`] )


] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Delivery ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule( get_delivery_details, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	gen1_address_details_without_names( [ delivery_left_margin, delivery_start_line,
					delivery_street, delivery_address_line1, delivery_city, delivery_state_1, delivery_postcode,
					delivery_end_line ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_line_rule( delivery_start_line, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	q0n(anything)

	, read_ahead(delivery_left_margin)

	, `delivery`, `address`, `:`

	, check( i_user_check( gen1_store_address_margin( delivery_left_margin ), delivery_left_margin(start), 0, 20 ) )


	%does not pick up stretford
] ).


%=======================================================================
i_line_rule( delivery_end_line, [ 
%=======================================================================

	or( [with(delivery_postcode)

	, [`telephone`, `:`] ])


] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_date, [ 
%=======================================================================


	 q0n(anything)

	, `Date`, `:`, tab

	, invoice_date(date), newline

	, trace( [ `invoice date`, invoice_date] )

]).

%=======================================================================
i_line_rule( get_delivery_date, [ 
%=======================================================================


	 q0n(anything)

	, `Delivery`, `Date`, `:`, q10(tab)

	, delivery_date(date)

	, trace( [ `delivery date`, delivery_date] )

]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_number, [ 
%=======================================================================

	q0n(anything)

	, `order`, `no`, `:`

	, q10([ peek_ahead( `MC853` ), type_of_supply(`G4`), invoice_type( `ZE` ) ])

	, read_ahead( [ delivery_location(sf), `/` ] )
	
	, order_number(s)

	, newline

	, trace( [ `order number`, order_number ] ) 


] ).




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_buyer_contact, [ 
%=======================================================================

	q0n(anything)

	, `Buyer`, `:`, tab

	, buyer_contact(s)

	, newline

	, trace([ `buyer contact`, buyer_contact ])

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_net_total_number, [
%=======================================================================

	 q0n(anything)

	, total_net(d)

	, newline

	, check(total_net(y) > 345 )

	, check(total_net(start) > 390 )

	, trace( [ `total net`, total_net ] )

] ).

%=======================================================================
i_line_rule( get_invoice_total_number, [
%=======================================================================

	q0n(anything)

	, total_invoice(d)

	, newline

	, check(total_invoice(y) > 345 )

	, check(total_invoice(start) > 390 )

	, trace( [ `total invoice`, total_invoice ] )	

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

	, qn0( [ peek_fails(line_end_line)

		, or([ line_invoice_line, shipping_instructions_line, line ])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ 
%=======================================================================

	
   	`qty`, `.`, tab, `unit`, tab, `description`



] ).


%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================

	or([ [`order`, `placed`, `subject`], [`purchase`, `order`, newline ] ])

] ).


%=======================================================================
i_rule_cut( get_shipping_instructions, [ 
%=======================================================================
	
	 shipping_instructions_line

	, qn0(line_continuation_line)

] ).




%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================
	 
	line_quantity(d), tab

	, trace( [ `line quantity`, line_quantity ] )

	, or([ [`each` , line_quantity_uom_code(`PC`) ]

	, [`m`, line_quantity_uom_code(`MTR`) ] ])

	, tab

	, trace( [ `line quantity uom code`, line_quantity_uom_code ] )

	, or([ [ `FLEET`, generic_item( [ line_item, sf, `(` ] ), generic_item( [ zzfminvnr, s, `)` ] )
	
			, zzfmorgref( `AMEON` ), zzfmcontracttype( `ZFPL` )
			
			, count_rule
			
		]
	
	, [ read_ahead(line_descr(s)), `hilti`, line_item(w), q0n(word) ]

	, [ line_descr(s) , line_item( f( [ begin, q(dec,5, 7), end ]) ) ]

	, [ line_descr(s), line_item( `MISSING` ) ]

	 ])

	, tab

	, trace( [ `line item`, line_item ] )	

	, trace( [ `line descr`, line_descr ] )	

	, q0n(anything)

	, line_net_amount(d)

	, trace( [ `line net amount`, line_net_amount ] )

	, q10([ with(invoice, delivery_date, DD), line_original_order_date(DD) ])

	, newline

		


] ).



%=======================================================================
i_line_rule_cut( shipping_instructions_line, [
%=======================================================================

	read_ahead(dummy(s1))	

	, check(dummy(start)> -290)

	, check(dummy(end) < 80)	

	, append(shipping_instructions(s1) , ` `,``)

	, newline


] ).


%=======================================================================
i_line_rule_cut( line_continuation_line, [
%=======================================================================

	peek_fails([ `order`, `placed`, `subject` ])

	, read_ahead(dummy(s1))	

	, check(dummy(start)> -290)

	, check(dummy(end) < 80)	

	, append(shipping_instructions(s1) , ` `,``)

	, newline

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).

