%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - KIER ORDER (HILTI) EDI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( kier_order_hilti_edi, `20 November 2013` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% i_pdf_parameter( space, 2 ).
% i_pdf_parameter( tab, 10 ).
% i_pdf_parameter( new_line, 6 ).
% i_pdf_parameter( font_size, 30 ).  
% i_pdf_parameter( max_pages, 1 ).
i_pdf_parameter( no_scaling, 1 ).
i_pdf_parameter( direct_object_mapping, 0 ).


i_format_postcode( X, X ).

i_user_field( invoice, delivery_street_2, `street 2 storage` ).
i_date_format( 'y-m-d' ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	suppliers_code_for_buyer(` `)

	,  static_variables_rule
	  
	, get_order_number
	  
	, get_order_date

	, get_supplier_details
	
	, get_buyer_details
	
	, get_delivery_details

	, get_customer_comments

	, currency(`GBP`)
	
	, get_invoice_lines

	, get_invoice_totals
	
	, get_bcfb_and_scfb

	, get_bcfb_and_scfb_from_name

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STATIC VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( static_variables_rule, [
%=======================================================================
		
	  buyer_registration_number( `GB-KIER` )
	  
	, or( [ [ test( test_flag ), supplier_registration_number( `Q01_100` ) ]
			, [ peek_fails( test( test_flag ) ), supplier_registration_number( `P11_100` ) ]
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
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================
		
	  q0n(line)

	, xml_tag_line( [ `BuyersOrderNumber`, order_number ] )
	
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
% SUPPLIER ADDRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_supplier_details, [ 
%=======================================================================

	  q0n(line)
	  
	, xml_tag_line( [ `Supplier` ] )
	  
	, 	q0n( [ or( [ xml_tag_line( [ `BuyersCodeForSupplier`, buyers_code_for_supplier ] )
	
						, xml_tag_line( [ `TaxNumber`, supplier_vat_number ] )
						
						, line
						
					] )
				
			] )
			
	, xml_tag_line( [ `/Supplier` ] )

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
	  
	, 	q0n( [ or( [ xml_tag_line( [ `SuppliersCodeForBuyer`, suppliers_code_for_buyer ] )
						
						, xml_tag_line( [ `AddressLine`, buyer_address_line ] )

						, xml_tag_line( [ `Street`, buyer_street ] )
						
						, xml_tag_line( [ `City`, buyer_city ] )
						
						, xml_tag_line( [ `PostCode`, buyer_postcode ] )
						
						, xml_tag_line( [ `State`, buyer_state ] )
						
						, xml_tag_line( [ `Name`, buyer_contact ] )
													
						, xml_tag_line( [ `Email`, buyer_email ] ) 
						
						, xml_tag_line( [ `BuyersOwnCompanyCode`, buyers_code_for_buyer_x ] )

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

	q0n(line)
	  
	, xml_tag_line( [ `DeliverTo` ] )
	  
	, 	q0n( [ or( [ xml_tag_line( [ `Party`, delivery_party_x ] )
						
						, xml_tag_line( [ `AddressLine`, delivery_address_line_x ] )

						, xml_tag_line( [ `Street`, delivery_street_2 ] )
						
						, xml_tag_line( [ `City`, delivery_street ] )
						
						, xml_tag_line( [ `PostCode`, delivery_postcode ] )
						
						, xml_tag_line( [ `State`, delivery_city ] )
						
						, xml_tag_line( [ `DeliveryNoteReference`, delivery_note_reference_x ] )
						
						, xml_tag_line( [ `BuyersCodeForLocation`, delivery_location ] )
						
						, xml_tag_line( [ `Switchboard`, buyer_ddi ] )
						
						, line
						
					] )
				
			] )
			
	, xml_tag_line( [ `/DeliverTo` ] )
	
	, check( i_user_check( gen_same, delivery_street_2, STREET ) )
	
	, delivery_street( STREET )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUSTOMER COMMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_customer_comments, [
%=======================================================================
		
	  q0n(line)

	, xml_tag_line( [ `Narrative`, customer_comments ] )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_totals, [
%=======================================================================

	  q0n(line)
	  
	, read_ahead( xml_number_tag_line( [ `GoodsValue`, total_net ] ) )
	
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
	
	, qn0( [ peek_fails( line_end_line )
	
			, or( [ [ line_quantity_uom_code_line, xml_number_tag_line( [ `Amount`, line_quantity ] )  ]
			
					, xml_tag_line( [ `LineNumber`, line_order_line_number ] )
	
					, line_price_uom_code_line
					
					, xml_tag_line( [ `SuppliersProductCode`, line_item ] )
					
					, xml_number_tag_line( [ `UnitPrice`, line_unit_amount ] )
						
					, xml_number_tag_line( [ `LineTotal`, line_net_amount ] ) 
					
					, xml_number_tag_line( [ `TaxValue`, line_vat_amount ] )

					, xml_number_tag_line( [ `Percentage`, line_percent_discount ] )
		
					, xml_tag_line( [ `Description`, line_descr ] )
					
					, line_extended_description_line
					
					, xml_tag_line( [ `DeliveryNoteReference`, line_delivery_note_number ] )
					
					, xml_number_tag_line( [ `TaxRate`, line_vat_rate ] )
					
					, xml_tag_line( [ `BuyersProductCode`, line_item_for_buyer ] )
					
					, line
					
				] )
				
		] )

] ).

%=======================================================================
i_line_rule( line_header_line, [
%=======================================================================

	  `<`, `OrderLine`
	
] ).

%=======================================================================
i_line_rule( line_end_line, [
%=======================================================================

	  `<`, `/`, `OrderLine`, `>`
	
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LIFNR & PARTN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_bcfb_and_scfb, [
%=======================================================================

	  with( invoice, order_number, Order )
	  
	, check( i_user_check( order_number_check, Order, SCFB, BCFB, Party ) )
	
	, buyer_party( Party )
	
	, buyers_code_for_buyer( BCFB )
	
	, suppliers_code_for_buyer( SCFB )
	
	, trace( [ `codes from the order number` ] )

] ).

%=======================================================================
i_user_check( order_number_check, Order, SCFB, BCFB, Party ):-
%=======================================================================

	  q_sys_sub_string( Order, 1, 3, BCFB_Code ) 
	, trace( code( BCFB_Code ) )
	, order_number_lookup( BCFB_Code, SCFB, Party )
	, strcat_list( [ `GBKIER`, BCFB_Code ], BCFB )
.


%=======================================================================
i_rule( get_bcfb_and_scfb_from_name, [
%=======================================================================

	  without( buyers_code_for_buyer )
	  
	, q0n(line)
	  
	, xml_tag_line( [ `Buyer` ] )
	
	, q(0,10,line)
	
	, read_ahead( [ xml_tag_line( [ `Party` ] ) ] )
	
	, bcfb_and_scfb_line

] ).


%=======================================================================
i_line_rule( bcfb_and_scfb_line, [
%=======================================================================

	  q0n(word)
	  
	, or( [
	
		  [ `Projects`, suppliers_code_for_buyer(`12258367`), buyers_code_for_buyer(`GBKIER024`)
		  
			, delivery_party( `KIER CONSTRUCTION MAJOR PROJECTS` ) 
			
		]
			
		, [ or([ `Oversea`, `Overseas`, `Infrast`, `Infrastructure` ]), suppliers_code_for_buyer(`12263548`), buyers_code_for_buyer(`GBKIER031`)

			, delivery_party( `KIER CONSTRUCTION INFRASTRUCTURE` )
			
		]
			
		, [ or([ `Northern`, `53` ]), suppliers_code_for_buyer(`12249433`), buyers_code_for_buyer(`GBKIER053`)
		
			, delivery_party( `KIER CONSTRUCTION NORTHERN` )
			
		]
			
		, [ `Scotland`, suppliers_code_for_buyer(`12313574`), buyers_code_for_buyer(`GBKIER058`)

			, delivery_party( `KIER CONSTRUCTION SCOTLAND` )
			
		]
			
		, [ `London`, suppliers_code_for_buyer(`12219914`), buyers_code_for_buyer(`GBKIER060`)

			, delivery_party( `KIER CONSTRUCTION LONDON` )

		]
			
		, [ `Eastern`, suppliers_code_for_buyer(`12259535`), buyers_code_for_buyer(`GBKIER066`)

			, delivery_party( `KIER CONSTRUCTION EASTERN` )
			
		]
			
		, [  `Southern`, suppliers_code_for_buyer(`20032343`), buyers_code_for_buyer(`GBKIER070`)

			, delivery_party( `KIER CONSTRUCTION SOUTHERN` )
			
		]
			
		, [ or([ `A270119`, `Wales`, `wale` ]), suppliers_code_for_buyer(`12255149`), buyers_code_for_buyer(`GBKIER080`)

			, delivery_party( `KIER CONST WESTERN & WALES` )
			
		]
			
		, [ `South`, suppliers_code_for_buyer(`12259139`), buyers_code_for_buyer(`GBKIER100`)

			, delivery_party( `KIER CONST CENTRAL SOUTH`)
			
		]
			
		, [ or([ `A130017`, `Central` ]), suppliers_code_for_buyer(`12259340`), buyers_code_for_buyer(`GBKIER090`)

			, delivery_party( `KIER CONSTRUCTION CENTRAL` )
			
		]

	] )
	
	, trace( [ `codes from the name` ] )
	
] ).


order_number_lookup( `024`, `12258367`, `KIER CONSTRUCTION MAJOR PROJECTS` ).
order_number_lookup( `031`, `12263548`, `KIER CONSTRUCTION INFRASTRUCTURE` ).
order_number_lookup( `053`, `12249433`, `KIER CONSTRUCTION NORTHERN` ).
order_number_lookup( `058`, `12313574`, `KIER CONSTRUCTION SCOTLAND` ).
order_number_lookup( `060`, `12219914`, `KIER CONSTRUCTION LONDON` ).
order_number_lookup( `066`, `12259535`, `KIER CONSTRUCTION EASTERN` ).
order_number_lookup( `070`, `20032343`, `KIER CONSTRUCTION SOUTHERN` ).
order_number_lookup( `080`, `12255149`, `KIER CONST WESTERN & WALES` ).
order_number_lookup( `100`, `12259139`, `KIER CONST CENTRAL SOUTH` ).
order_number_lookup( `090`, `12259340`, `KIER CONSTRUCTION CENTRAL` ).



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
