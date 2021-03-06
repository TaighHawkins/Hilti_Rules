%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - CH SANITAR FREI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( ch_sanitar_frei, `27 February 2015` ).

i_pdf_parameter( no_scaling, 1 ).

i_date_format( _ ).
i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	  
	, get_xml_detail( [ `Prozess`, ( `ID_Auftrag`, order_number ) ] )
	
	, get_xml_detail( [ `Datum`, invoice_date, date ] )

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
	
	, buyer_registration_number( `CH-ADAPTRI` )

	, or( [ 
		[ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	] )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`2100`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, or( [ [ test( test_flag ), suppliers_code_for_buyer( `10482553` ) ]
		, suppliers_code_for_buyer( `10482553` )
	] )
	
	, set( reverse_punctuation_in_numbers )
	
	, sender_name( `Sanitar Frei AG` )

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

	, xml_tag_line( [ `Prozess`, ( `ID_Auftrag`, order_number ) ] )

	
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
	  
	, xml_tag_line( [ `Kunde` ] )
	
	, q(0,2,line), xml_tag_line( [ `Name`, buyer_contact_x ] )
	, check( buyer_contact_x = ConX )
	, check( string_to_capitalised( ConX, Con ) )
	, buyer_contact( Con )
	, delivery_contact( Con )
	
	, xml_tag_line( [ `Email`, buyer_email ] )
	, check( buyer_email = Email )
	, delivery_email( Email )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_delivery_details, [ 
%=======================================================================

	  xml_tag_line( [ `ADR_Lieferort` ] )

	, q0n(
		or( [ 
			xml_tag_line( [ `ADR_Firma`, delivery_party ] )

			, xml_tag_line( [ `ADR_ADR1`, delivery_street ] )
			
			, xml_tag_line( [ `ADR_PLZ`, delivery_postcode ] )
			
			, xml_tag_line( [ `ADR_Ort`, delivery_city ] )
			
			, line
		] )
	)
	
	, generic_line( [ [ `<`, `/`, `ADR_Lieferort` ] ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  total_net( `0` )
	  
	, check( total_net = Net )
	, total_invoice( Net )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule_cut( line_header_line, [ `<`, `Artikel` ] ).
%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  peek_ahead( line_header_line )
	  
	, q0n(
		or( [ 
			generic_line( [ [ `<`, `Line_Item_ID`, `>`, generic_item( [ line_order_line_number, d ] ) ] ] )
			
			, xml_tag_line( [ `Artikel`, ( `Art_Nr_Anbieter`, line_item ) ] )

			, xml_tag_line( [ `Art_Txt_Kurz`, line_descr ] )
			
			, xml_tag_line( [ `Art_Menge`, line_quantity, d ] )

			, xml_tag_line( [ `LiefDat_Kundenwunsch`, line_original_order_date, date ] )
			
			, line
			
		] )
	)
	
	, generic_line( [ [ `<`, `/`, `Artikel` ] ] )
	, count_rule

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )	
	, line_order_line_number(NEXT_LINE_NUMBER)

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

%=======================================================================
i_rule_cut( get_xml_detail( [ Tag, ( Attribute, Attribute_Var )] ), [ 
%=======================================================================

	q0n(line), xml_tag_line( [ Tag, ( Attribute, Attribute_Var ) ] )
	
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
i_line_rule_cut( xml_tag_line( [ Name, ( Attribute, Attribute_Value ) ] ), [ xml_tag_rule( [ Name, ( Attribute, Attribute_Value ) ] ) ] ).
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
i_rule_cut( xml_tag_rule( [ Name, ( Attribute, Attribute_Var ) ] ), [
%=======================================================================

	`<`, Name, q0n(anything)
	
	, Attribute, `=`, `"`
	
	, Read_Variable, `"`

	, trace( [ Variable_Name, Attribute_Var ] )
] )

:-

	q_sys_is_atom( Attribute_Var )	
	, Read_Variable =.. [ Attribute_Var, sf ]
	, sys_string_atom( Variable_Name, Attribute_Var )

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