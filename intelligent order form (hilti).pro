%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - INTELLIGENT ORDER FORM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( intelligent_order_form, `28 April 2015` ).

i_date_format( _ ).

i_pdf_parameter( max_pages, 1 ).

%=======================================================================
%		User Fields
%=======================================================================

i_user_field( line, zzfminvnr, `ZZFM InvRef` ).
i_user_field( line, zzfmorgref, `ZZFM orgref` ).
i_user_field( line, zzfmcontracttype, `ZZFM contracttype` ).

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

fleet_thing( `zzfmcontracttype` ).
fleet_thing( `zzfmorgref` ).
fleet_thing( `zzfminvnr` ).

defect( _, missing( buyer_registration_number ) ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list(1, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  buyer_party( `LS` )
	
	, supplier_party( `LS` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100 ` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, get_buyer_registration_number
	
	, check_fleet_order_type

	, [ q0n(line), get_type_of_supply ]

	, [ q0n(line), get_suppliers_code_for_buyer ]

	, [ q0n(line), get_delivery_note_number ]

	, [ q0n(line), get_new_ship_to ]
	
	, delivery_party_rule

%	, [ q0n(line), get_delivery_location ]

	, [ q0n(line), get_buyer_contact ]

	, [ q0n(line), get_buyer_ddi ]

	, [ q0n(line), get_buyer_email ]

	, [ q0n(line), get_delivery_contact ]

	, [ q0n(line), get_delivery_ddi ]

	, [ q0n(line), get_delivery_email ]

	, [ q0n(line), get_order_number ]

	, [ q0n(line), get_order_date ]

	, [ q0n(line), get_due_date ]
	
	, get_without_due_date

	, [ q0n(line), get_customer_comments ]

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

	, [ qn0(line), invoice_total_line ]

	, [ q0n(line), footer_line ]


] ).


%=======================================================================
i_line_rule_cut( footer_line, [ 
%=======================================================================

	  `sources`, `valid`, `on`

	, q0n(anything)

	, tab, narrative(s1), newline
	  
	, check(narrative(page) = 1)
	
	, trace([`Form Name`, narrative])

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHECK ORDER TYPE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( check_fleet_order_type, [ 
%=======================================================================

	q(0,10,line), generic_horizontal_details( [ [ q10( `Hilti` ), `Fleet`, `Order` ] ] )
	
	, set( fleet_order )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER REGISTRATION NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_registration_number, [ 
%=======================================================================

	  q0n(line), purchase_order_line
	  
	, buyer_registration_number_line
	
	, supplier_line
	
	, q10( [ check( buyer_registration_number = Reg )
		, check( q_sys_sub_string( Reg, 1, _, `IE` ) )
		, remove( agent_code_3 )
		, agent_code_3( `4600` )
	] )

] ).

%=======================================================================
i_line_rule( purchase_order_line, [ 
%=======================================================================

	  or( [ [ q10( `REQUISITION` ), `PURCHASE`, `ORDER` ]
	  
			, [ `PURCHASING`, `REQUISITION` ]
			
			, [ q10( `Hilti` ), `Fleet`, `Order` ]
			
	] )

] ).

%=======================================================================
i_line_rule( buyer_registration_number_line, [ 
%=======================================================================

	  buyer_registration_number(s1), newline
	  
	, check( buyer_registration_number(end) < -250 )
	
	, trace( [ `buyer reg`, buyer_registration_number ] )

] ).

%=======================================================================
i_line_rule( supplier_line, [ 
%=======================================================================

	 `Supplier`, `:`

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TYPE OF SUPPLY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_type_of_supply, [ 
%=======================================================================

	  q0n(anything)

	,`delivery`, `time`, `:`, tab

	, dummy(s1), tab

	, type_of_supply(s1), newline

	, trace( [ `type of supply`, type_of_supply ] ) 

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUPPLIERS CODE FOR BUYER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_suppliers_code_for_buyer, [ 
%=======================================================================

	  `sold`, `-`, `to`, tab

	, suppliers_code_for_buyer(s1)

	, tab, `delivery`, `time`

	, trace( [ `suppliers code for buyer`, suppliers_code_for_buyer ] ) 

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY PARTY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( delivery_party_rule, [ 
%=======================================================================

	  q(0,15,line), delivery_party_line

] ).

%=======================================================================
i_line_rule( delivery_party_line, [
%=======================================================================

	  `Delivery`, `Address`, `:`, tab( 50 )
	
	, read_ahead( delivery_left_margin(s1) )
	  
	, delivery_party(s1), tab	
	
	, check( delivery_party(end) < 0 )

	, trace( [ `delivery party`, delivery_party ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY NOTE NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_delivery_note_number, [
%=======================================================================

	`ship`, `-`, `to`, tab

	, or( [ [ or( [ [ `NEW`, `SHIP`, `-`, `TO` ]
	
						, [ q10( `#` ), `N`, `/`, `A` ]
						
					] )
					
				, set(new_ship_to), trace( [ `new ship to` ] ) 
				
			]
	
			, [ delivery_note_number(s1) , newline, trace( [ `delivery note number`, delivery_note_number ] )  ]
		
	] )

] ).

%=======================================================================
i_rule( get_new_ship_to, [ 
%=======================================================================

	  test(new_ship_to)
	
	, q0n(line), customer_comments_header

	, delivery_street_two_line( 1, 170, 500 )

	, delivery_street_line( 1, 170, 500 )

	, delivery_city_line( 1, 170, 500 )

	, read_ahead( postcode_line ), or([ delivery_postcode_line( 1, 185, 500 ), delivery_postcode(`OO00OO`) ])

	, trace( [ `new ship to address`, delivery_city, delivery_postcode ] ) 

] ).

%=======================================================================
i_line_rule( delivery_street_two_line, [
%=======================================================================

	  delivery_street_two(s)

	, trace( [ `delivery street two`, delivery_street_two] ) 

] ).

%=======================================================================
i_line_rule( delivery_street_line, [
%=======================================================================

	  delivery_street(s)

	, q10( [ check( i_user_check( gen_same, delivery_street_two, STREET ) ), delivery_street(STREET) ] )

	, trace( [ `delivery street`, delivery_street] ) 

] ).


%=======================================================================
i_line_rule( delivery_city_line, [
%=======================================================================

	  delivery_city(s)

	, trace( [ `delivery city`, delivery_city] ) 

] ).


%=======================================================================
i_line_rule( postcode_line, [ q0n(anything), `post`, `code` ]).
%=======================================================================

%=======================================================================
i_line_rule( delivery_postcode_line, [
%=======================================================================

	  delivery_postcode(pc)

	, trace( [ `delivery postcode`, delivery_postcode] ) 

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY LOCATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_delivery_location, [
%=======================================================================

	  q0n(anything)

	,or( [ [ `Delivery`, or( [ `Location`, `Address` ] ) ]
	
			, [ `Job`, `No` ]
			
	] )
	
	, or( [ `.`, `:` ] ), tab

	, delivery_location(s1), newline
	
	, check( delivery_location(start) > 0 )

	, trace( [ `delivery location`, delivery_location ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_buyer_contact, [ 
%=======================================================================

	 or( [ [ `site`, `contact`]
	 
		, [`buyers`, `name` ]
		
		, [ `Buyers`, `First`, `&`, `Last`, `Name` ]
		
	] ), `:`, tab	

	, buyer_contact(s1), newline

	, trace( [ `buyer contact`, buyer_contact ] ) 

] ).

%=======================================================================
i_line_rule( get_buyer_ddi, [ 
%=======================================================================

	  q0n(anything)

	, or([ [ `contact`, `phone`], [`buyers`, `phone` ] ]), `:`, tab

	, buyer_ddi(s1), newline

	, trace( [ `buyer ddi`, buyer_ddi ] ) 

] ).

%=======================================================================
i_line_rule( get_buyer_email, [ 
%=======================================================================

	  q0n(anything)

	,`email`, `:`, tab

	, read_ahead([ q0n(anything), `@` ])

	, buyer_email(s1), newline

	, trace( [ `buyer email`, buyer_email ] ) 

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_delivery_contact, [ 
%=======================================================================

	 `delivery`, `contact`, `:`, q10(tab)

	, delivery_contact(s1), check(delivery_contact(start) < -200 )

	, trace( [ `delivery contact`, delivery_contact ] ) 

] ).

%=======================================================================
i_line_rule( get_delivery_ddi, [ 
%=======================================================================


	 `delivery`, `phone`, `:`, q10(tab)

	, delivery_ddi(s1), check(delivery_ddi(start) < -200 )

	, trace( [ `delivery ddi`, delivery_ddi ] ) 

] ).

%=======================================================================
i_line_rule( get_delivery_email, [ 
%=======================================================================

	`delivery`, `email`, `:`, q10(tab)

	, read_ahead([ q0n(anything), `@` ])

	, delivery_email(s1), check(delivery_email(start) < -200 )

	, trace( [ `delivery email`, delivery_email ] ) 

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

	, or( [ [ `purchase`, `order` ]
	
			, [ `Contract` ]
			
	] ), `no`, or( [ `.`, `:` ] ), tab

	, order_number(s1)

	, trace( [ `order number`, order_number ] ) 

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( get_order_date, [ 
%=======================================================================

	  or( [ [ `authorised`, `:`,  q0n(anything) ]
		
			, [ `Cost`, `Responsible`, `:` , q0n(anything) ]
			
			, [q0n(anything), `date`, `:`, tab ]
			
	] )

	
	, invoice_date(date), gen_eof

	, trace( [ `invoice date`, invoice_date ] ) 

] ).

%=======================================================================
i_line_rule( get_due_date, [ 
%=======================================================================

	  q0n(anything)

	, `delivery`, `date`, `:`, tab

	, due_date(date), newline

	, trace( [ `due date`, due_date ] ) 

] ).

%=======================================================================
i_line_rule( get_without_due_date, [ 
%=======================================================================

	  without( due_date )
	  
	, due_date( Today_string )
	
	, trace( [`due date found`, due_date ]) 

] ) 
:- 
	date_get( today, Today )

	, date_string( Today, 'd/m/y', Today_string )
.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_customer_comments, [ 
%=======================================================================

	customer_comments_header

	, customer_comments(``), shipping_instructions(``)
	
	, customer_comments_line

	, q(3, 0, customer_comments_line)

] ).

%=======================================================================
i_line_rule( customer_comments_header, [ 
%=======================================================================

	q0n(anything)

	, read_ahead(special(w)), or( [ `special`, `Offloading` ] )

	, read_ahead(instructions(w)), `instructions`, `:`
	
	, trace( [ `found header` ] )

] ).

%=======================================================================
i_line_rule( customer_comments_line, [ 
%=======================================================================

	nearest(special(start), 10, 30)

	, qn0( [ read_ahead(dcc(s)), check(dcc(start) < instructions(end)), append(customer_comments(s), ``, ` `)
	
		, or( [ [ q10( tab ), `C`, `/`, `O` ]

				, [ gen_eof] 
			
		] ) 
		
	] )

	, check(i_user_check(gen_same, customer_comments, CC)), shipping_instructions(CC)


] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( invoice_total_line, [
%=======================================================================

	  or( [ `sub`, `monthly` ] )
	  
	, `total`, q10( tab ), or( [ `£`, `€` ] ), q10(tab)

	, or( [ [ read_ahead(total_invoice(d))

			, total_net(d)

			, newline
			
		]
		
		, [ `-`, newline, set( no_total_validation )
			, total_net( `0` )
			, total_invoice( `0` )
		]
		
	] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	 line_header_line

	, qn0( [ peek_fails(line_end_line)

		, or([ line_invoice_line
		
			, line_deal_line
		
			, line

			])

		] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Item`, tab, `Description`, tab ] ).
%=======================================================================
%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	`sub`, `total`

] ).

%=======================================================================
i_line_rule_cut( line_deal_line, [ peek_fails( test( fleet_order ) ), `deal`, invoice_type( `ZE` ), trace( [ `Deal Found` ] ) ] ).
%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  line_item(sf), q10( tab )

	, trace( [ `line item`, line_item ] )

	, line_descr(s1), tab

	, trace([ `line description`, line_descr ])

	, min_order_qty(d), tab

	, line_quantity_uom_code(s1), tab

	, trace([ `line quantity uom code`, line_quantity_uom_code ])

	, line_quantity(d), tab

	, trace([ `line quantity`, line_quantity ])

	, or( [ `£`, `€` ] ), q10(tab), or( [ line_unit_amount_x(d), `-` ] ), tab

	, per(d), tab

	, or( [ `£`, `€` ] ), q10(tab)
	
	, or( [ [ line_net_amount(d)
			, trace( [ `line net amount`, line_net_amount ] )
		]
		
		, `-`
		
	] )

	, with( invoice, due_date, DATE )

	, line_original_order_date( DATE )

	, newline

] ):- not( grammar_set( fleet_order ) ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  line_item(sf), q10( tab )
	, trace( [ `line item`, line_item ] )

	, line_descr(s1), tab
	, trace([ `line description`, line_descr ])

	, line_quantity(d), tab
	, trace([ `line quantity`, line_quantity ])

	, generic_item( [ zzfmorgref, s1, tab ] )
	
	, q10( generic_item( [ zzfminvnr, s1, tab ] ) )
	
	, contract_length(d), tab

	, or( [ `£`, `€` ] ), q10(tab)
	
	, or( [ [ line_net_amount(d)
			, trace( [ `line net amount`, line_net_amount ] )
		]
		
		, `-`
		
	] )
	
	, zzfmcontracttype( `ZFP` )
	
	, line_quantity_uom_code( `PC` )

	, with( invoice, due_date, DATE )
	, line_original_order_date( DATE )
	, newline
	
	, count_rule

] ):- grammar_set( fleet_order ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 1, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).