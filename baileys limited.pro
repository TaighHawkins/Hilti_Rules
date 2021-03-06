%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - BAILEYS LIMITED
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( baileys_limited, `04 August 2014` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 i_pdf_parameter( space, 1 ).
% i_pdf_parameter( tab, 10 ).
% i_pdf_parameter( new_line, 6 ).
% i_pdf_parameter( font_size, 30 ).  
% i_pdf_parameter( max_pages, 1 ).

i_pdf_parameter( no_scaling, 1 ).

i_pdf_parameter( direct_object_mapping, 0 ).

i_format_postcode( X, X ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1 ).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1 ).

i_user_field( invoice, delivery_street_2, `street 2 storage` ).
i_user_field( invoice, net_x, `net storage` ).
i_date_format( 'y-m-d' ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

defect( _, missing( line_item ) ).
i_op_param( send_result( defect( _ ) ) , _, _, _, true ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	suppliers_code_for_buyer(` `)

	,  static_variables_rule
	
	, get_order_type
	  
	, get_order_number
	  
	, get_order_date
	
%	, get_delivery_location

	, get_buyer_details
	
	, get_delivery_details

	, get_customer_comments

	, currency(`GBP`)
	
	, get_invoice_lines

	, get_invoice_totals

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STATIC VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( static_variables_rule, [
%=======================================================================
		
	  buyer_registration_number( `GB-BAILEY` )
	  
	, or( [ [ test( test_flag ), supplier_registration_number( `Q01_100` ) ]
			, [ peek_fails( test( test_flag ) ), supplier_registration_number( `P11_100` ) ]
		] )	
		
	, or( [ [ test( test_flag ), suppliers_code_for_buyer( `10755543` ) ]
			, [ peek_fails( test( test_flag ) ), suppliers_code_for_buyer( `12239456` ) ]
		] )
	
	, agent_code_3( `4400` )
	, agent_code_2( `01` )
	, agent_code_1( `00` )
	, agent_name( `GBADAPTRIS` )
	
	, supplier_party( `LS` )
	
	, buyer_party( `LS` )
	
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET ORDER TYPE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_type, [ q0n(line), order_type_line ] ).
%=======================================================================
i_line_rule( order_type_line, [
%=======================================================================
		
	  `<`, `BuyersOrderNumber`, q0n(anything), `>`
	  
	, q0n(anything), `/`, q0n(anything), `/`
	
	, q0n(anything), `<`
	
	, invoice_type( `ZE` )
	
] ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================
		
	  q0n(line), or( [ xml_tag_line( [ `BuyersOrderNumber`, order_number ] )
		
							, xml_tag_line( [ `BuyersOrderNumberPreserve`, order_number ] )
							
						] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY LOCATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_location, [
%=======================================================================
		
	  q0n(line), xml_tag_line( [ `ProjectCode`, delivery_location ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_date, [
%=======================================================================

	  q0n(line)
	  
	, order_date_line

] ).

%=======================================================================
i_line_rule( order_date_line, [
%=======================================================================

	  `<`, `OrderDate`, `>`
	  
	, set( regexp_allow_partial_matching )

	, invoice_date(f([begin,q(dec,4,4),end])), `-`

	, append( invoice_date(f([begin,q(dec,2,2),end])), `-`, `` ), `-`

	, append( invoice_date(f([begin,q(dec,2,2),end])), `-`, `` ), or( [ `T`, `<` ] )

	, clear( regexp_allow_partial_matching )

	, trace( [ `invoice_date`, invoice_date ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_details, [
%=======================================================================

	  q0n(line)
	  
	, xml_tag_line( [ `Buyer` ] )
	  
	, 	q(0,30, [ or( [ xml_tag_line( [ `SuppliersCodeForBuyer`, suppliers_code_for_buyer ] )
						
						, xml_tag_line( [ `AddressLine`, buyer_address_line ] )

						, xml_tag_line( [ `Street`, buyer_street ] )
						
						, xml_tag_line( [ `City`, buyer_city ] )
						
						, xml_tag_line( [ `PostCode`, buyer_postcode ] )
						
						, xml_tag_line( [ `State`, buyer_state ] )
						
						, xml_tag_line( [ `Name`, buyer_contact ] )
						
						, xml_tag_line( [ `Switchboard`, buyer_ddi ] )
													
						, xml_tag_line( [ `Email`, buyer_email ] ) 

						, line
						
					] )
				
			] )
			
	, xml_tag_line( [ `/Buyer` ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule( get_delivery_details, [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  delivery_party( `NG BAILEY LTD` )
	  
	, q0n(line)
	  
	, xml_tag_line( [ `DeliverTo` ] )
	  
	, 	q(0,30, [ or( [ xml_tag_line( [ `Street`, delivery_street_2 ] )
						
						, xml_tag_line( [ `City`, delivery_street ] )
						
						, xml_tag_line( [ `PostCode`, delivery_postcode ] )
						
						, xml_tag_line( [ `State`, delivery_city ] )
						
						, xml_tag_line( [ `Switchboard`, buyer_ddi ] )
						
						, line
						
					] )
				
			] )
			
	, xml_tag_line( [ `/DeliverTo` ] )
	
	, q10([ check( i_user_check( gen_same, delivery_street_2, STREET ) )
	
	, delivery_street( STREET ) ])

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( text_line, [ `<`, or( [ `BuyersProductCode`, `SuppliersProductCode` ] ), `>`, `TEXT` ] ).
%=======================================================================
i_rule( get_customer_comments, [
%=======================================================================
		
	  q0n(line), text_line

	, q(0,3,line), xml_tag_line( [ `Description`, customer_comments ] )
	
	, check( i_user_check( gen_same, customer_comments, NARR ) )
	
	, shipping_instructions( NARR )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_totals, [
%=======================================================================

	  q0n(line), read_ahead( xml_number_tag_line( [ `GoodsValue`, total_net ] ) )
	
	, xml_number_tag_line( [ `GoodsValue`, total_invoice ] )

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
	  
	, trace( [ `found header` ] )
	  
	, peek_fails( text_line_rule )
	
	, trace( [ `not text line` ] )
	
	, or( [ [ q( 0, 15, line ), carriage_line
	
					, q( 0, 15, line ), xml_number_tag_line( [ `LineTotal`, net_x ] )
					
					, q( 0, 5, line ), read_ahead( line_end_line ) 
				]
	
			  , [ trace( [ `not carriage line` ] )
			  
				, q0n( or( [ [ line_quantity_uom_code_line, xml_number_tag_line( [ `Amount`, line_quantity ] )  ]
			
					, xml_tag_line( [ `LineNumber`, line_order_line_number ] )

					, code_and_descr
	
					, line_price_uom_code_line

					, [ xml_tag_line( [ `SuppliersProductCode`, line_item ] ), set( got_line_item ) ]
					
					, xml_number_tag_line( [ `UnitPrice`, line_unit_amount_x ] )
			
					, xml_number_tag_line( [ `LineTotal`, line_net_amount ] ) 
		
					, [ xml_tag_line( [ `Description`, line_descr ] )
					
						, or( [ test( got_line_item )
						
							, [ check( i_user_check( check_descr_for_item, line_descr, Item ) )
							
								, line_item( Item )
								
								, trace( [ `Line item from description`, line_item ] )
								
							]
							
							, trace( [ `Failed to find code` ] )
							
						] )
						
					]
					
					, line_extended_description_line
					
					, xml_tag_line( [ `BuyersProductCode`, line_item_for_buyer ] )
					
					, xml_tag_line( [ `PreferredDate`, line_original_order_date ] )
					
					, line
				] )
				)
			]
		] )
		
	, line_end_line
	
	, clear( got_line_item )

] ).


%=======================================================================
i_user_check( check_descr_for_item, Descr, Item ):-
%=======================================================================

	sys_string_split( Descr, ` `, Descr_Split )	
	, q_sys_member( Item, Descr_Split )	
	, q_regexp_match( `^\\d{4,}$`, Item, _ )

.

%=======================================================================
i_rule_cut( code_and_descr, [
%=======================================================================

	read_ahead(  xml_tag_line( [ `SuppliersProductCode` ] ) )

	, or([ [ xml_tag_line( [ `SuppliersProductCode`, line_item ] ) ] 

		, [ line, q01(line), read_ahead( code_in_descr_line ) ]

		])

	, set( got_line_item )

] ).

%=======================================================================
i_line_rule_cut( code_in_descr_line, [
%=======================================================================

	  q0n( anything)
	  
	, `hilti`, q01(word), line_item(d)

	, trace([ `item code in description`, line_item ])
	
] ).


%=======================================================================
i_rule( text_line_rule, [
%=======================================================================

	  q( 0, 7, line )
	  
	, text_line
	
] ).

%=======================================================================
i_line_rule( carriage_line, [
%=======================================================================

	  `<`, `Description`, `>`, or( [ `Carriage`, `CARRIAGECHARGE`, `freight`, `delivery` ] )
	  
	, trace( [ `found carriage` ] )
	
] ).

%=======================================================================
i_line_rule( line_header_line, [
%=======================================================================

	  `<`, or( [ `OrderLine`, `OrderLineAction` ] )
	  
] ).

%=======================================================================
i_line_rule( line_end_line, [
%=======================================================================

	  `<`, `/`, `OrderLine`
	
] ).

%=======================================================================
i_line_rule( line_extended_description_line, [
%=======================================================================

	  `<`, `ExtendedDescription`, `>`
	  
	, append( line_descr(sf), ``, `` )
	
	, q0n( [ tab, append( line_descr(sf), ``, `` ) ] )
	
	, q01( tab )
	
	, `<`
	
	, trace( [ `line descr`, line_descr ] )
	
] ).

%=======================================================================
i_line_rule( line_quantity_uom_code_line, [
%=======================================================================

	  `<`, `Quantity`, `UOMCode`, `=`, `"`
	  
	, line_quantity_uom_code(sf), `"`
	  
	, trace( [ `line quantity uom`, line_quantity_uom_code ] )
	
] ).

%=======================================================================
i_line_rule( line_price_uom_code_line, [
%=======================================================================

	  `<`, `Price`, `UOMCode`, `=`, `"`
	  
	, line_price_uom_code(sf), `"`
	  
	, trace( [ `line price uom`, line_price_uom_code ] )
	
] ).




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read an XML tag
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule_cut( xml_tag_line( [ NAME ] ), [ `<`, NAME, q0n(anything), `>` ] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( xml_tag_line( [ NAME, VALUE ] ), [
%=======================================================================

	`<`, NAME, q0n(anything), `>`

	, q10( tab )

	, VALUE

	, q10( tab )

	, `<`
] )

:-
	q_sys_is_string( VALUE )

. %end%

%=======================================================================
i_line_rule_cut( xml_tag_line( [ NAME, VARIABLE ] ), [
%=======================================================================

	`<`, NAME, q0n(anything), `>`

	, q10( tab )

	, READ_VARIABLE

	, q0n( [ tab, READ_MORE_VARIABLE ] )

	, q10( tab )

	, or( [ `<`
	
		, [ `(`, `Test`, `)` ]
		
	] )

	, trace( [ VARIABLE_NAME, VARIABLE ] )
] )

:-

	q_sys_is_atom( VARIABLE )
		
	, READ_VARIABLE =.. [ VARIABLE, sf ]
	
	, READ_MORE_VARIABLE =.. [ append, READ_VARIABLE, ` `, `` ]

	, sys_string_atom( VARIABLE_NAME, VARIABLE )

. %end%


%=======================================================================
i_line_rule_cut( xml_number_tag_line( [ NAME ] ), [ `<`, NAME, q0n(anything), `>` ] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( xml_number_tag_line( [ NAME, VALUE ] ), [
%=======================================================================

	`<`, NAME, q0n(anything), `>`

	, q10( tab )

	, VALUE

	, q10( tab )

	, `<`
] )

:-
	q_sys_is_string( VALUE )

. %end%

%=======================================================================
i_line_rule_cut( xml_number_tag_line( [ NAME, VARIABLE ] ), [
%=======================================================================

	`<`, NAME, q0n(anything), `>`

	, q10( tab )

	, READ_VARIABLE

	, q0n( [ tab, READ_MORE_VARIABLE ] )

	, q10( tab )

	, `<`

	, trace( [ VARIABLE_NAME, VARIABLE ] )
] )

:-

	q_sys_is_atom( VARIABLE )
		
	, READ_VARIABLE =.. [ VARIABLE, d ]
	
	, READ_MORE_VARIABLE =.. [ append, READ_VARIABLE, ` `, `` ]

	, sys_string_atom( VARIABLE_NAME, VARIABLE )

. %end%
