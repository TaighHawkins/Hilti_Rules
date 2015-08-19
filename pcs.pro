%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - PCS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( pcs_rules, `13 October 2014` ).

i_date_format( 'mon/d/y' ).
i_format_postcode( X, X ).

i_user_field( line, qualf_098_item, `Item used in Qualf 098 segment` ).
bespoke_e1edp19_segment( [ `098`, qualf_098_item ] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  buyer_party( `LS` )

%	, buyer_registration_number( `Customer` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `CA-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, agent_name(`CA_ADAPTRIS`)
	, agent_code_3(`6800`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, set( no_uom_transform )

     % TEST / PROD VARIANTS
	,  [q0n(line), get_production_scfb ]

%	, suppliers_code_for_buyer( `11232639` ) % test
%	, suppliers_code_for_buyer( `10685515` ) % production

	,[q0n(line), get_delivery_address ]

	,[q0n(line), get_delivery_contact ]
	,[q0n(line), get_delivery_ddi ]
	,[q0n(line), get_delivery_fax ]

	,[q0n(line), get_buyer_contact ]
	,[q0n(line), get_buyer_email ]
	,[q0n(line), get_buyer_ddi ]
	,[q0n(line), get_buyer_fax ]

	,[q0n(line), get_order_number ]

	,[q0n(line), get_order_date ]

%	, customer_comments( `Customer Comments` )
%	,[q0n(line), customer_comments_line ] 

%	, shipping_instructions( `Shipping Instructions` )
	,[qn0(line), shipping_instructions_line ]

	, get_invoice_lines
	
	, [ test( repair ), delivery_note_reference( `repair order` ) ]

	, [ without(delivery_note_reference), q0n(line), total_invoice_line ]

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SCFB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%=======================================================================
i_line_rule( get_production_scfb, [
%=======================================================================

	  q0n(anything)

	, `ship`, `to`, q01(tab)
	
	, generic_item( [ shipping_info, s1 ] )
	
	, check( i_user_check( get_shipping_information, shipping_info, Flag, ToS, CC, COR, BCFL, Test, Live ) )
	
	, trace( [ `Flag`, Flag ] )
	
	, set( division, Flag )
	
	, type_of_supply( ToS )
	
	, cost_centre( CC )
	
	, contract_order_reference( COR )
	
	, buyers_code_for_location( BCFL )
	
	, or( [ [ test(test_flag), suppliers_code_for_buyer( Test ) ]    %TEST
	
		, suppliers_code_for_buyer( Live )                    		 %PROD
		
	] )
	
	, q10( or( [ 
	
			[ test( division, rocanville )

				, delivery_street( `16 KM North of Rocanville` ), set( street_fixed )
				
			]

			, [ test( division, allan )
				
				, delivery_street( `4 KM NORTH OF ALLAN ON HWY 397` ), set( street_fixed )
			
			]

		] )
		
	)

] ).

%=======================================================================
i_user_check( get_shipping_information, Shipping, Flag, ToS, CC, COR, BCFL, Test, Live ):-
%=======================================================================

	string_to_upper( Shipping, Shipping_U )
	, pcs_shipping_lookup( Shipping_Key, ToS, CC, COR, BCFL, Test, Live )
	, q_sys_sub_string( Shipping_U, _, _, Shipping_Key )
	, string_to_lower( Shipping_Key, Shipping_Key_L )
	, string_string_replace( Shipping_Key_L, ` `, `_`, Flag )
.

pcs_shipping_lookup( `CORY`			, `01`, `Standard`			, `CPT`, `SASKATOON`			, `11232639`, `10687031` ).
pcs_shipping_lookup( `ROCANVILLE`	, `01`, `Standard`			, `CPT`, `ROCANVILLE`			, `11232650`, `10685515` ).
pcs_shipping_lookup( `LANIGAN`		, `N4`, `HNA - Cust Acct`	, `EXW`, `DHL ACCOUNT# 778779`	, `11240926`, `10687560` ).
pcs_shipping_lookup( `ALLAN`		, `01`, `Standard`			, `CIP`, `ALLAN`				, `10453563`, `10685893` ).
pcs_shipping_lookup( `NEW BRUNSWICK`, `01`, `Standard`			, `CIP`, `SUSSEX`				, `10685950`, `10685950` ).
pcs_shipping_lookup( `CASSIDY LAKE`	, `01`, `Standard`			, `CIP`, `SUSSEX`				, `15895680`, `15895680` ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_address, [
%=======================================================================
 
	 get_delivery_party_line

	, q10(nothing_line)

	, or( [ peek_fails( test( division, new_brunswick ) ), get_delivery_dept_line ] )

	, q10(nothing_line)

	, or( [ test(street_fixed), get_delivery_street_line ] )

	, q10(nothing_line), q01(line)

	, or([ [ delivery_city_and_region_line

			, q10(nothing_line)

			, delivery_postcode_line ]

		, [ delivery_city_and_region_and_postcode_line ]

	])

	 
] ).

%=======================================================================
i_line_rule( nothing_line, [
%=======================================================================
 
	peek_fails( nearest(-50, 10, 10) )

] ).


%=======================================================================
i_line_rule( get_delivery_party_line, [
%=======================================================================
 
	q0n(anything)

	, `ship`, `to`, q01(tab)

	, delivery_party(s1)

	, trace([ `delivery party`, delivery_party ])

] ).


%=======================================================================
i_line_rule( get_delivery_dept_line, [
%=======================================================================
 
	nearest(-50, 10, 10) 

	, delivery_dept(s1)

	, trace([ `delivery dept`, delivery_dept ])

] ).


%=======================================================================
i_line_rule( get_delivery_street_line, [
%=======================================================================
 
	nearest(-50, 10, 10) 

	, delivery_street(s1)

	, trace([ `delivery street`, delivery_street ])

] ).

%=======================================================================
i_line_rule( delivery_city_and_region_line, [
%=======================================================================
 
	nearest(-50, 10, 10) 
	
	, or([ [ delivery_city(s), `,`], delivery_city(s) ])

	, trace([ `delivery city`, delivery_city ])

	, or([ [`alberta`, delivery_state(`AB`) ]

		, [`British`, `columbia`, delivery_state(`BC`) ]

		, [`manitoba`, delivery_state(`MB`) ]

		, [`new`, `brunswick`, delivery_state(`NB`) ]

		, [`new`, `foundland`, delivery_state(`NF`) ]

		, [`northwest`, `territories`, delivery_state(`NT`) ]

		, [`Nova`, `Scotia`, delivery_state(`NS`) ]

		, [`Ontario`, delivery_state(`ON`) ]

		, [`prince`, `edward`, `island`, delivery_state(`PE`) ]

		, [`Quebec`, delivery_state(`PQ`) ]

		, [`Saskatchewan`, delivery_state(`SK`) ]

		, [`Yukon`, `Territories`, delivery_state(`YT`) ]

])

		, trace([ `delivery state`, delivery_state ])

] ).


%=======================================================================
i_line_rule( delivery_postcode_line, [
%=======================================================================
 
	nearest(-50, 10, 10) 

	, delivery_postcode(s1)

	, trace([ `delivery postcode`, delivery_postcode ])

] ).



%=======================================================================
i_line_rule( delivery_city_and_region_and_postcode_line, [
%=======================================================================

	nearest(-50, 10, 10) 
	
	, or([ [ delivery_city(s), `,`], delivery_city(s) ])

	, delivery_state(f([begin, q(alpha,2,2), end])), trace([ `delivery state`, delivery_state ])

	, delivery_postcode(w1), append(delivery_postcode(w1), ` `, ``)

	, or([ tab, newline ]) 


]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY EMAIL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_email, [ 
%=======================================================================

	delivery_contact_header

	, delivery_email_line



] ).


%=======================================================================
i_line_rule( delivery_email_line, [ 
%=======================================================================

	q0n(anything)

	, or([ [ `dauvin`, delivery_email(`rpdauvin@potashcorp.com`) ]

		, [ `kish`, delivery_email(`bryan.kish@potashcorp.com`) ]

		, [ `baxter`, delivery_email(`clayton.baxter@potashcorp.com`) ]

		, [ `eckersley`, delivery_email(`mreckersley@potashcorp.com`) ]

		, [ `verhelst`, delivery_email(`kcverhelst@potashcorp.com`) ] 

		, [ `krieger`, delivery_email(`doreen.krieger@potashcorp.com`) ] 
		
		, [ `Zerbin`, delivery_email( `JLZerbin@potashcorp.com` ) ]
		
		, [ `Grosse`, delivery_email( `mark.grosse@potashcorp.com` ) ]
		
		, [ `Gilmour`, delivery_email( `gayla.gilmour@potashcorp.com` ) ]
		
		, [ `Brown`, delivery_email( `suzanne.brown@potashcorp.com` ) ]
		
		, [ `Card`, delivery_email( `brent.card@potashcorp.com` ) ]

])

	, trace([ `delivery contact`, delivery_contact ])

] ).




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_contact, [ 
%=======================================================================

	delivery_contact_header

	, delivery_contact_line



] ).


%=======================================================================
i_line_rule( delivery_contact_header, [ 
%=======================================================================

	`buyer`, tab, `terms`, newline


] ).

%=======================================================================
i_line_rule( delivery_contact_line, [ 
%=======================================================================

	delivery_contact(s1)

	, trace([ `delivery contact`, delivery_contact ])

] ).


%=======================================================================
i_line_rule( get_delivery_ddi, [ 
%=======================================================================

	q0n(anything)

	, `phone`, `-`, q10(tab)	

	, delivery_ddi(s1)

	, trace([ `delivery ddi`, delivery_ddi ])

] ).


%=======================================================================
i_line_rule( get_delivery_fax, [ 
%=======================================================================

	q0n(anything)

	, `fax`, `-`, q10(tab)	

	, delivery_fax(s1)

	, trace([ `delivery ddi`, delivery_ddi ])

] ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER EMAIL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_email, [ 
%=======================================================================

	buyer_contact_header

	, buyer_email_line

] ).


%=======================================================================
i_line_rule( buyer_email_line, [ 
%=======================================================================

	q0n(anything)

	, or( [ [ `dauvin`, buyer_email(`rpdauvin@potashcorp.com`) ]

		, [ `kish`, buyer_email(`bryan.kish@potashcorp.com`) ]

		, [ `baxter`, buyer_email(`clayton.baxter@potashcorp.com`) ]

		, [ `eckersley`, buyer_email(`mreckersley@potashcorp.com`) ]

		, [ `verhelst`, buyer_email(`kcverhelst@potashcorp.com`) ] 
		
		, [ `krieger`, buyer_email(`doreen.krieger@potashcorp.com`) ] 
		
		, [ `Zerbin`, buyer_email( `JLZerbin@potashcorp.com` ) ]
		
		, [ `Grosse`, buyer_email( `mark.grosse@potashcorp.com` ) ]
		
		, [ `Gilmour`, buyer_email( `gayla.gilmour@potashcorp.com` ) ]
		
		, [ `Brown`, buyer_email( `suzanne.brown@potashcorp.com` ) ]
		
		, [ `Card`, buyer_email( `brent.card@potashcorp.com` ) ]

		, [ `Candy`, buyer_email( `bob.candy@potashcorp.com` ) ]

		, [ `McGee`, buyer_email( `derek.mcgee@potashcorp.com` ) ]

		, [ `WILSON`, buyer_email( `anne.wilson@potashcorp.com` ) ]
		
		, [ `Psyden`, buyer_email( `rick.pysden@potashcorp.com` ) ]
		
		, [ `DOIRON`, buyer_email( `lori.doiron@potashcorp.com` ) ]


	] )
	
	, check( buyer_email = Email )
	
	, delivery_email( Email )

	, trace([ `buyer email`, buyer_email ])

] ).




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	buyer_contact_header

	, buyer_contact_line



] ).


%=======================================================================
i_line_rule( buyer_contact_header, [ 
%=======================================================================

	`buyer`, tab, `terms`, newline


] ).

%=======================================================================
i_line_rule( buyer_contact_line, [ 
%=======================================================================

	buyer_contact(s1)

	, trace([ `buyer contact`, buyer_contact ])

] ).


%=======================================================================
i_line_rule( get_buyer_ddi, [ 
%=======================================================================

	q0n(anything)

	, `phone`, `-`, q10(tab)	

	, buyer_ddi(s1)

	, trace([ `buyer ddi`, buyer_ddi ])

] ).


%=======================================================================
i_line_rule( get_buyer_fax, [ 
%=======================================================================

	q0n(anything)

	, `fax`, `-`, q10(tab)	

	, buyer_fax(s1)

	, trace([ `buyer ddi`, buyer_ddi ])

] ).





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_number, [ 
%=======================================================================

	q0n(anything)

	, `WITHOUT`, `A`, `PURCHASE`, `ORDER`, `.`, tab

	, order_number(w), newline

	, trace([ `order number`, order_number ])


] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	order_date_header

	, q10(line)

	, order_date_line

]).

%=======================================================================
i_line_rule( order_date_header, [ 
%=======================================================================

	q0n(anything)

	,`order`, `date`

	, newline

]).

%=======================================================================
i_line_rule( order_date_line, [ 
%=======================================================================

	q0n(anything)
	
	, invoice_date(f( [ begin, q(alpha,3,3), end, q(alpha,0,7) ] ) )

	, check(invoice_date(start) > 250)
	
	, append( invoice_date(d), `/`, `` ), `,`

	, append( invoice_date(d), `/`, `` )

	, trace( [ `invoice date`, invoice_date] )

	, newline

]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SHIPPING INSTRUCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%=======================================================================
i_line_rule( shipping_instructions_line, [
%=======================================================================

	`note`, `:`

	, shipping_instructions(s1), newline

	, trace( [ `shipping instructions`, shipping_instructions ] )

] ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( total_invoice_line, [
%=======================================================================

	`total`, `value`, `of`, `this`, `purchase`, `order`, `$`, q01(tab)

	, read_ahead(total_net(d))

	, total_invoice(d)

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
	 
	, peek_fails( [ or( [ [ q( 0, 20, line ), ams_line ], [ q( 0, 20, line ), repair_order_line] ] ) ] )

	, qn0( [ peek_fails(line_end_line)

		, or([ get_invoice_line, continuation_line, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `item`, `inventory`, `#` ] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	or([ [`total`, `value`, `of`, `this`, `purchase`, `order` ], [`purchasing`, `department`, `must`] ])

] ).

%=======================================================================
i_line_rule_cut( repair_order_line, [
%=======================================================================

	q0n(anything), `repair`, set( repair )
	
	, trace( [ `repair order` ] )

] ).

%=======================================================================
i_line_rule_cut( ams_line, [
%=======================================================================

	q0n(anything)
	
	, set( regexp_allow_partial_matching )
	
	, ams( f( [ q(alpha("A"),1,1), q(alpha("M"),1,1), q(alpha("S"),1,1) ] ) )
	
	, clear( regexp_allow_partial_matching )
	
	, set( repair )
	
	, trace( [ `repair order - found through AMS` ] )

] ).

%=======================================================================
i_rule_cut( get_invoice_line, [
%=======================================================================

	or([ [ trace( [ `try first` ] ), read_ahead(get_item_code), invoice_values_line ]
		
		, [ trace( [ `try second` ] ), invoice_values_with_item ]

		, [ invoice_values_line, 
		
			or( [ [ trace( [ `try new third` ] ), q(0,5,continuation_line ), hilti_no_hash_line ]
			
				, [ trace( [ `try fourth` ] ), q(0,5,continuation_line), hilti_no_line ]
				
				, [ trace( [ `try fifth` ] ), q(0,5,continuation_line), hilti_item_no_line ]
				
				, [ trace( [ `try sixth` ] ), q(0,5,continuation_line), unknown_part_no_line ]
						
				, [ trace( [ `try seventh` ] ), number_line ]
				
				, [ trace( [ `Missing` ] ), line_item( `Missing` ) ]
				
			] )
			
		]
		
	] )
	
	, q10( [ test( got_ea ), check( line_item = Item ), qualf_098_item( Item ) ] )
	
	, clear( got_ea )
	
] ).

%=======================================================================
i_line_rule_cut( number_line, [
%=======================================================================

	q0n(word), `#`, line_item(w) 
	
	, trace( [ `line item from number line`, line_item ] )

] ).

%=======================================================================
i_line_rule_cut( hilti_no_hash_line, [
%=======================================================================

	q0n(word), `ITEM`, `#`, line_item(w) 
	
	, trace( [ `line item from item # line`, line_item ] )

] ).

%=======================================================================
i_line_rule_cut( hilti_item_no_line, [
%=======================================================================

	q0n(word), `ITEM`, `No`, `.`, line_item(w), or( [ newline, [ `,`, append( line_descr(s1), ` `, `` ) ] ] )
	
	, trace( [ `line item from item no . line`, line_item ] )

] ).

%=======================================================================
i_line_rule_cut( unknown_part_no_line, [
%=======================================================================

	q0n(word), or( [ `Unknown`, `Uknown` ] ), `Part`, `Number`, line_item(w)
	
	, trace( [ `line item from unknown part line`, line_item ] )

] ).

%=======================================================================
i_line_rule_cut( hilti_no_line, [
%=======================================================================

	q0n(word), `hilti`, `part`, `number`, line_item(w) 
	
	, trace( [ `line item from hilti item line`, line_item ] )

] ).

%=======================================================================
i_line_rule_cut( get_item_code, [
%=======================================================================

	q0n(anything)
	
	, or( [ [ or([ `item`, [`p`, `/`, `n`, q10(`-`) ] ]), q10(`#`) ]
	
			, [ `#` ]
			
	 ] )
	
	, line_item(f( [ begin, q(any,4,10), end ] ) )
	
	, trace( [ `line item from get item code`, line_item ] )

] ).


%=======================================================================
i_line_rule_cut( invoice_values_line, [
%=======================================================================

	  line_order_line_number(w)

	, trace([`line no`, line_order_line_number ])

	, or([ [ line_item_for_buyer(w), q01( tab ) ], tab]), wh(d), tab

	, trace([`line item for buyer`, line_item_for_buyer ])

	, line_quantity(d)

	, trace([`line quantity`, line_quantity ])

	, or( [ [ test( division, allan ), `EA`, line_quantity_uom_code( `PC` ), set( got_ea ) ]
	
		, uom_code(w)
		
	] )

	, trace([`line quantity uom code`, uom_code ])

	, q10( read_ahead([ q0n(anything), `ams`, delivery_note_reference(`for repair`) ]) )

	, line_descr(s1), tab

	, trace([`line descr`, line_descr ])

	, or( [ line_unit_amount_x(d), [ `No`, `Charge` ] ] ), tab

	, or( [ line_net_amount(d), [ `No`, `Charge`, tab, line_net_amount( `0` ) ] ] )

	, trace([`line net amount`, line_net_amount ])

	, line_original_order_date_x(w)

	, prepend(line_original_order_date_x(d), ``, ` `)

	, `/`, append(line_original_order_date_x(d), ` 20`, ``)

	, trace([`line original order date`, line_original_order_date ])


] ).

%=======================================================================
i_line_rule_cut( invoice_values_with_item, [
%=======================================================================

	line_order_line_number(w)

	, trace([`line no`, line_order_line_number ])

	, or([line_item_for_buyer(w), tab]), wh(d), tab

	, trace([`line item for buyer`, line_item_for_buyer ])

	, line_quantity(d)

	, trace([`line quantity`, line_quantity ])

	, or( [ [ test( division, allan ), test( test_flag ), `EA`, line_quantity_uom_code( `PC` ), set( got_ea ) ]
	
		, uom_code(w)
		
	] )

	, trace([`line quantity uom code`, uom_code ])

	, or([ read_ahead( line_item(f([begin, q(dec,5,9), end])) )

		, read_ahead([ q0n(word)
		
							, or( [ [ or([ [`hilti`, `part`, `number`], [`p`, `/`, `n`, q10(`-`)] ]), q10(`#`) ]
							
									, [ `#` ]
									
								] )
								
							, line_item(f( [ begin, q(any,4,10), end ] ) ) ])

	   ])

	, q10( read_ahead([ q0n(anything), `ams`, delivery_note_reference(`for repair`) ]) )

	, line_descr(s1), tab

	, trace([`line descr`, line_descr ])

	, line_unit_amount_x(d), tab

	, line_net_amount(d)

	, trace([`line net amount`, line_net_amount ])

	, line_original_order_date_x(w)

	, prepend(line_original_order_date_x(d), ``, ` `)

	, `/`, append(line_original_order_date_x(d), ` 20`, ``)

	, trace([`line original order date`, line_original_order_date ])


] ).

%=======================================================================
i_line_rule_cut( continuation_line, [
%=======================================================================

	read_ahead( dummy(s1) )

	, check(dummy(start) > -275 )

	, check(dummy(end) < 120)

	, q10( read_ahead([ q0n(anything), `ams`, delivery_note_reference(`for repair`) ]) )

	, append(line_descr(s), ` `, ``)

	, newline

] ).



i_op_param( orders05_idocs_first_and_last_name( buyer_contact, NAME1, NAME2 ), _, _, _, _):- 

	  result( _, invoice, delivery_party, PARTY )
	  
	, result( _, invoice, buyer_contact, NAME1 )
	
		, ( q_sys_sub_string( PARTY, _, _, `CORY` )

			, q_sys_member( NAME2, [ `P C S LTD CORY DIV` ] )
			
			;
			
			q_sys_sub_string( PARTY, _, _, `ROCANVILLE` )

			, q_sys_member( NAME2, [ `P C S LTD ROCANVILLE DIV` ] )
			
			; 
			
			q_sys_sub_string( PARTY, _, _, `LANIGAN` )

			, q_sys_member( NAME2, [ `P C S LTD LANIGAN DIV` ] )
			
			).
	
	

i_op_param( orders05_idocs_first_and_last_name( delivery_contact, NAME3, NAME4 ), _, _, _, _) :-

	  result( _, invoice, delivery_party, PARTY )
	  
	, result( _, invoice, delivery_contact, NAME3 )
	
		, ( q_sys_sub_string( PARTY, _, _, `CORY` )

			, q_sys_member( NAME4, [ `P C S LTD CORY DIV` ] )
			
			;
			
			q_sys_sub_string( PARTY, _, _, `ROCANVILLE` )

			, q_sys_member( NAME4, [ `P C S LTD ROCANVILLE DIV` ] )
			
			; 
			
			q_sys_sub_string( PARTY, _, _, `LANIGAN` )

			, q_sys_member( NAME4, [ `P C S LTD LANIGAN DIV` ] )
			
			).
