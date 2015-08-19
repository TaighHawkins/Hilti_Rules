%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - TERMIGAS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( termigas, `27 July 2015` ).

i_date_format( _ ).


%=======================================================================
i_analyse_invoice_fields_first
%-----------------------------------------------------------------------
:- i_trim_address_line.
%=======================================================================
i_trim_address_line
%-----------------------------------------------------------------------
:-
	result( _, invoice, delivery_address_line, AL ),
	( q_sys_sub_string( AL, _, _, `CIG` ); q_sys_sub_string( AL, _, _, `CUP` ) ),
	
	sys_string_trim( AL, ALTrim ),
	
	sys_retract( result( _, invoice, delivery_address_line, AL ) ),
	assertz_derived_data( invoice, delivery_address_line, ALTrim, i_trimmed_address_line ),
	!
.
%=======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	set(reverse_punctuation_in_numbers)

	, buyer_party( `LS` )

%	, buyer_registration_number( `Customer` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `IT-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`7500`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, or( [ [ test( test_flag ), suppliers_code_for_buyer( `10672877` ) ]  %TEST
				, suppliers_code_for_buyer( `13061410` )  			%PROD
		] )
		
	, buyers_code_for_buyer(``)

	, get_customer_comments

	,[q0n(line), get_delivery_address ]

	,[q0n(line), get_order_number ]

	,[q0n(line),  get_order_date ]

	,[q0n(line), buyer_contact_line ]

	,[q0n(line), cig_line ]

	,[q0n(line), cup_line ]

	, get_invoice_lines

	,[ q0n(line), get_net_total_number]

	%,[ q0n(line), get_invoice_total_number]

%	, total_net(`0`)

%	, total_invoice(`0`)

	, replicate_address

] ).



%=======================================================================
i_line_rule( cig_line, [ 
%=======================================================================
	
	q0n(anything)

	, `codice`, `cig`, `:`, q10( `.` )
	
	, peek_fails( or( [ `Codice`, `.` ] ) )

	, delivery_address_line(`CIG:`), append(delivery_address_line(w), ``, ` `)

]).

%=======================================================================
i_line_rule( cup_line, [ 
%=======================================================================
	
	q0n(anything)

	, `codice`, `cup`, `:`, q10( `.` )
	
	, peek_fails( or( [ `Codice`, `.` ] ) )

	, append(delivery_address_line(w), `CUP:`, ``)

]).



%=======================================================================
i_rule( replicate_address, [
%=======================================================================

	q10([ with(invoice, buyer_contact, BC), delivery_contact(BC) ])

	, q10([ with(invoice, buyer_email, BE), delivery_email(BE) ])

	, q10([ with(invoice, buyer_ddi, BI), delivery_ddi(BI) ])

	, q10([ with(invoice, buyer_fax, BF), delivery_ddi(BF) ])


] ).




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================
 
	  delivery_party(`TERMIGAS SPA`)

	, delivery_header_line

	 , q(0,2,line)

	 , delivery_dept_line

 	, q(0,2,line)

	 , delivery_street_line

	 , q(0,2,line)

	 , delivery_postcode_and_city

] ).

%=======================================================================
i_line_rule( delivery_header_line, [ 
%=======================================================================

	`Indirizzo`, `di`, `consegna`, tab, `Spettabile`,  newline

	, trace([ `delivery header found` ])
	

]).

%=======================================================================
i_line_rule( delivery_dept_line, [ 
%=======================================================================
	
	delivery_dept(s)

	, check(delivery_dept(end) < 0)

	, trace([ `delivery party`, delivery_party ])
	

]).

%=======================================================================
i_line_rule( delivery_street_line, [ 
%=======================================================================

	delivery_street(s)

	, check(delivery_street(end) < 0)

	, trace([ `delivery street`, delivery_street ])
	

]).

%=======================================================================
i_line_rule( delivery_postcode_and_city, [ 
%=======================================================================

	  delivery_postcode(f( [ begin, q(dec,5,5), end ] ) )

	, check(delivery_postcode(end) < -200)

	, trace([ `delivery postcode`, delivery_postcode ])

	, or([ [delivery_city(s)

	, check(delivery_city(end) < 0)

	, trace([ `delivery city`, delivery_city ])

	, delivery_state( f( [ begin, q(alpha,2,2), end ]) ) ] , [ delivery_city(s)

	, check(delivery_city(end) < 0) ]  ])

	, or([ tab, newline])

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	order_date_header_line

	,q(0, 2, line), order_date_line


] ).

%=======================================================================
i_line_rule( order_date_header_line, [ 
%=======================================================================

	q0n(anything)

	,`numero`, tab, `data`

	, trace([ `order date header found` ])

] ).

%=======================================================================
i_line_rule( order_date_line, [ 
%=======================================================================


	 q0n(anything)

	, invoice_date(date)

	, newline

	, trace( [ `invoice date`, invoice_date] )

]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	order_number_header_line

	, q(0, 3, line), order_number_line

] ).



%=======================================================================
i_line_rule( order_number_header_line, [ 
%=======================================================================

	q0n(anything)

	,`numero`, tab, `data`

	, trace([ `order number header found` ])
] ).




%=======================================================================
i_line_rule( order_number_line, [ 
%=======================================================================

	 q0n(anything)

	, nearest_word(210, 10, 10)

	, order_number(w)

	, check(order_number(end) < 300 )

	, trace( [ `order number`, order_number ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( buyer_contact_line, [ 
%=======================================================================

	`riferimento`, `interno`, tab	

	, buyer_contact(w), q01( prepend(buyer_contact(s), ``, ` `))

	, tab, `termini`

	, trace([ `buyer contact`, buyer_contact ])

	%, check( i_user_check( gen_string_to_upper, buyer_contact, CU  ) )

	%, buyer_contact( CU )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_customer_comments, [ 
%=======================================================================

	q0n(line), peek_ahead( customer_comments_id_line )
	
	, peek_ahead( gen_count_lines( [ generic_line( [ [ `Attenzione`, `:`, gen_eof ] ] ), Count ] ) )
	
	, customer_comments_line( Count, -500, 0 )

] ).

%=======================================================================
i_line_rule( customer_comments_id_line, [ 
%=======================================================================

	  or( [ [ read_ahead( [ q0n(word), or( [ `Consegna`, `Prego`, `Nostro`, `referente` ] )
	  
			, q0n(word), `Sig` ] )
		]
		
		, [ read_ahead( dummy(w) ), check( dummy(font) = 0 ), check( dummy(size) = 7 ) ]
		
	] )
] ).

%=======================================================================
i_line_rule( customer_comments_line, [ 
%=======================================================================
	
	read_ahead( [ customer_comments(s1), newline ] )
	
	, shipping_instructions(s1), newline
	
	, trace( [ `comments`, customer_comments ] )

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

	,`Totale`, `Iva`, `Esc`, `.`, tab

	, read_ahead( total_net(d) )
	
	, total_invoice(d)

	, newline

	, trace( [ `total net`, total_net ] )

] ).

%=======================================================================
i_line_rule( get_invoice_total_number, [
%=======================================================================

	q0n(anything)

	,`Totale`, `Iva`, `Esc`, `.`, tab

	, total_invoice(d)

	, newline

	, trace( [ `total invoice`, total_invoice ] )	

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

	, qn0( [ peek_fails(line_end_line)

		, or([ get_invoice_line, non_invoice_line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ or([ [`pianificata`,  newline], [`q`, `.`, tab, `pianificata`,  newline] ]) ] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( non_invoice_line, [
%=======================================================================

	dummy(s), newline


	] ).



%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	`Totale`, `Iva`, `Esc`, `.`, tab

	] ).

%=======================================================================
i_line_rule_cut( get_invoice_line, [
%=======================================================================

	line_no(d), `-`, no(d)

	, or( [ line_item( f( [  q(alpha("H"),1,1), q(alpha("I"),1,1), q(alpha("L"),1,1), begin, q(dec,1, 20), end ]) )

		, line_item( `Missing` ), dummy(s1)
		
	] ),tab

	, trace([`line item`, line_item])

	, line_descr(s), q10( tab )
	
	, check( line_descr(end) < -86 )

	, trace([`line descr`, line_descr])

	, or( [ [ line_quantity(d)

				, trace([`line quantity`, line_quantity])

				, line_quantity_uom_code(w1)

				, trace( [`line quantity uom code`, line_quantity_uom_code] )
			
			]

			, [ line_quantity_uom_code(w1), tab

				, trace( [ `line quantity uom code`, line_quantity_uom_code ] )

				, line_quantity(d)

				, trace( [ `line quantity`, line_quantity ] )
				
			] 
			
	] )

	, tab

	, q0n(anything)

	, tab, line_net_amount(d)

%	, line_net_amount(`0`)

	, q10(tab)

	, line_original_order_date(date)

	, trace([ `line original order date`, line_original_order_date])

	, newline


] ).

