%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - DE HOERLEMANN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( de_hoerlemann, `15 December 2014` ).

i_pdf_parameter( no_scaling, 1 ).

i_date_format( _ ).
i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	  
	, get_order_number
	
	, get_order_date

	, get_xml_detail( [ `Party_ID`, ( `type`, `supplier_specific` ), suppliers_code_for_buyer, s ] )

	, get_delivery_details

	, get_buyer_contact

	, check( i_user_check( gen_cntr_set, 20, 0 ) )
	
	, get_totals

	, get_invoice_lines

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

	, buyer_registration_number( `DE-ADAPTRI` )

	, or( [ 
		[ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	] )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`5000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, set( reverse_punctuation_in_numbers )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================	  
	  
	  q0n(line)
	  
	, xml_tag_line( [ `ORDER_ID`, order_number_x ] )
	
	, q0n(line)
	
	, xml_tag_line( [ `COST_CATEGORY_ID`, ( `type`, `cost_center` ), order_number_y, s ] )
	
	, check( order_number_x = X )
	, check( order_number_y = Y )
	, check( strcat_list( [ X, `/`, Y ], Order ) )
	, order_number( Order )
	
	, trace( [ `Order number`, Order ] )
	
] ).

%=======================================================================
i_rule( get_order_date, [
%=======================================================================	  
	  
	  q(0,30,line)
	 
	, generic_line( [ [ `<`, `ORDER_DATE`, `>`, set( regexp_allow_partial_matching ), generic_item( [ invoice_date, date ] ) ] ] )
	, clear( regexp_allow_partial_matching )
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTACT DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  q(0,25,line)
	  
	, xml_tag_line( [ `Contact` ] )
	
	, xml_tag_line( [ `Contact_Name`, buyer_contact ] )
	
	, xml_tag_line( [ `Phone`, buyer_ddi_x ] )
	, check( strip_string2_from_string1( buyer_ddi_x, `()- `, DDI1 ) )
	, check( string_string_replace( DDI1, `+49`, `0`, DDI ) )
	
	, buyer_ddi( DDI )
	
	, xml_tag_line( [ `Email`, buyer_email ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_delivery_details, [ 
%=======================================================================

	  xml_tag_line( [ `Delivery_Party` ] )
	  
	, without( delivery_party )

	, q0n(
		or( [ 
			xml_tag_line( [ `Name`, delivery_party ] )
			
			, xml_tag_line( [ `Contact_Name`, delivery_contact ] )
			
			, [ without( delivery_ddi ), xml_tag_line( [ `Phone`, delivery_ddi_x ] )
				
				, check( strip_string2_from_string1( delivery_ddi_x, `()- `, DDI1 ) )
				, check( string_string_replace( DDI1, `+49`, `0`, DDI ) )
				
				, delivery_ddi( DDI )
			]
			
			, xml_tag_line( [ `Email`, delivery_email ] )
			
			, xml_tag_line( [ `Street`, delivery_street ] )
			
			, xml_tag_line( [ `Zip`, delivery_postcode ] )
			
			, xml_tag_line( [ `City`, delivery_city ] )
			
			, line
		] )
	)
	
	, generic_line( [ [ `<`, `/`, `Delivery_Party` ] ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  qn0(line), xml_tag_line( [ `TOTAL_AMOUNT`, total_net ] )
	  
	, check( total_net = Net )
	, total_invoice( Net )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule_cut( line_header_line, [ `<`, `Order_Item`, `>` ] ).
%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line
	  
	, q0n(
		or( [ 
			generic_line( [ [ `<`, `Line_Item_ID`, `>`, generic_item( [ line_order_line_number, d ] ) ] ] )
			
			, xml_tag_line( [ `Supplier_Aid`, line_item ] )
			
			, xml_tag_line( [ `Buyer_Aid`, line_item_for_buyer ] )
			
			, xml_tag_line( [ `Description_Long`, line_descr ] )
			
			, xml_tag_line( [ `Quantity`, line_quantity ] )
			
			, xml_tag_line( [ `Order_Unit`, line_quantity_uom_code ] )
			
			, xml_tag_line( [ `Price_Amount`, line_unit_amount ] )
			
			, xml_tag_line( [ `Price_Line_Amount`, line_net_amount ] )
			
			, generic_line( [ 
				[ `<`, `Delivery_End_Date`, `>`, set( regexp_allow_partial_matching )
					, generic_item( [ line_original_order_date, date ] ), clear( regexp_allow_partial_matching ) 
				] 
			] )
			
			, line
			
		] )
	)
	
	, generic_line( [ [ `<`, `/`, `Order_Item` ] ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get XML Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule_cut( get_xml_detail( [ Tag, Variable ] ), [ get_xml_detail( [ Tag, Variable, s ] ) ] ).
%=======================================================================
i_rule_cut( get_xml_detail( [ Tag, Variable, Parameter ] ), [ 
%=======================================================================

	q0n(line), xml_tag_line( [ Tag, Variable, Parameter ] )
	
] ).

%=======================================================================
i_rule_cut( get_xml_detail( [ Tag, ( Attribute, Attribute_Value ), Variable, Parameter ] ), [ 
%=======================================================================

	q0n(line), xml_tag_line( [ Tag, ( Attribute, Attribute_Value ), Variable, Parameter ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read an XML tag
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule_cut( xml_tag_line( [ Name ] ), [ 
%=======================================================================

	`<`
	
	, or( [ [ check( q_sys_sub_string( Name, 1, 1, `/` ) ), `/`
			, check( q_sys_sub_string( Name, 2, _, NameLessSlash ) )			
		]
	
		, [ check( not( q_sys_sub_string( Name, 1, 1, `/` ) ) )
			, check( Name = NameLessSlash )
		]
		
	] )
	
	, NameLessSlash, q0n(anything), `>` 
	
] ).

%=======================================================================
i_line_rule_cut( xml_tag_line( [ Name, Value ] ), [
%=======================================================================

	`<`, Name, q0n(anything), `>`

	, q10( tab )

	, Value

	, q10( tab )

	, `<`
] ):-	q_sys_is_string( Value ). %end%


%=======================================================================
i_line_rule_cut( xml_tag_line( [ Name, ( Attribute, Attribute_Value ), Variable, Par ] ), [ xml_tag_rule( [ Name, ( Attribute, Attribute_Value ), Variable, Par ] ) ] ).
%=======================================================================
i_line_rule_cut( xml_tag_line( [ Name, Variable, Par ] ), [ xml_tag_rule( [ Name, Variable, Par ] ) ] ).
%=======================================================================
i_line_rule_cut( xml_tag_line( [ Name, Variable ] ), [ xml_tag_rule( [ Name, Variable, s ] ) ] ).
%=======================================================================

%=======================================================================
i_rule_cut( xml_tag_rule( [ Name, Variable, Par ] ), [
%=======================================================================

	`<`, Name, q0n(anything), `>`

	, q10( tab )

	, Read_Variable

	, or( [ [ check( Par = s ), q0n( [ tab, Read_More_Variable ] ) ]
	
		, [ check( not( Par = s ) ) ]
		
	] )

	, q10( tab )

	, `<`

	, trace( [ Variable_Name, Variable ] )
] )

:-

	q_sys_is_atom( Variable )	
	, Read_Variable =.. [ Variable, Par ]
	, Read_More_Variable =.. [ append, Read_Variable, ` `, `` ]
	, sys_string_atom( Variable_Name, Variable )

. %end%

%=======================================================================
i_rule_cut( xml_tag_rule( [ Name, ( Attribute, Attribute_Value ), Variable, Par ] ), [
%=======================================================================

	`<`, Name, q0n(anything), Attribute, `=`, `"`, Attribute_Value, `"`
	
	, q0n(anything), `>`

	, q10( tab )

	, Read_Variable

	, or( [ [ check( Par = s ), q0n( [ tab, Read_More_Variable ] ) ]
	
		, [ check( not( Par = s ) ) ]
		
	] )

	, q10( tab )

	, `<`

	, trace( [ Variable_Name, Variable ] )
] )

:-

	q_sys_is_atom( Variable )	
	, Read_Variable =.. [ Variable, Par ]
	, Read_More_Variable =.. [ append, Read_Variable, ` `, `` ]
	, sys_string_atom( Variable_Name, Variable )

. %end%