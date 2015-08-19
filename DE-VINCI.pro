%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - DE_VINCI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( de_vinci_rules, `21 April 2012` ).

i_pdf_parameter( direct_object_mapping, 0 ).

i_date_format( 'y-m-d' ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	 set( purchase_order )

	, buyer_party( `LS` )

	, buyer_registration_number( `DE-VINCI` )

	, supplier_party( `LS` )

	, supplier_registration_number( `P11_100` )
	
	, currency( `5000` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`5000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, customer_comments( `` )

	, shipping_instructions( `` )

	, type_of_supply( `` )

	, cost_centre( `` )

	, suppliers_code_for_buyer( `` )

	, get_delivery_details

	, get_buyer_details

	, get_buyer_email

	, get_order_number_and_date

	, get_invoice_lines

%	, gen_get_from_cache_at_end

%	, gen_set_cache

	, force_result( `success` )

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

	, xml_tag_line( [ `E1EDKA1` ] )

	, q0n(line)

	, xml_tag_line( [ `PARVW`, `AG` ] )

	, q10( [ q0n(line), xml_tag_line( [ `TELF1`, buyer_ddi ] ) ] )

	, q10( [ q0n(line), xml_tag_line( [ `TELFX`, buyer_fax ] ) ] )

	, q10( [ q0n(line), xml_tag_line( [ `BNAME`, buyer_contact ] ) ] )
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER EMAIL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_email, [
%=======================================================================

	q0n(line)

	, xml_tag_line( [ `E1EDKT1` ] )

	, xml_tag_line( [ `TDID`, `F91` ] )

	, q0n(line)

	, xml_tag_line( [ `E1EDKT2` ] )

	, q10( [ q0n(line), xml_tag_line( [ `TDLINE`, buyer_email ] ) ] )
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [ 
%=======================================================================

	q0n(line)

	, xml_tag_line( [ `E1EDKA1` ] )
	
	, q0n(line)

	, xml_tag_line( [ `PARVW`, `WE` ] )

	, q0n(line)

	, buyers_code_for_buyer_line

	, q0n(line)

	, xml_tag_line( [ `NAME1`, delivery_party ] )

	, xml_tag_line( [ `NAME2`, delivery_dept ] )

	, q10( xml_tag_line( [ `NAME3`, delivery_address_line ] ) )

	, q10( xml_tag_line( [ `NAME4`, delivery_address_line ] ) )

	, q10( [ q0n(line), or([ xml_tag_line( [ `STRAS`, delivery_street ] ), xml_tag_line( [ `STRS2`, delivery_street ] )   ] ) ] )

%	, q10( [ q0n(line), xml_tag_line( [ `STRS2`, delivery_street_x ] ) ] )

	, q0n(line), xml_tag_line( [ `ORT01`, delivery_city ] )

	, q0n(line), xml_tag_line( [ `PSTLZ`, delivery_postcode ] )

	, q0n(line), xml_tag_line( [ `LAND1`, delivery_country_code ] )
] ).

%=======================================================================
i_line_rule( buyers_code_for_buyer_line, [ 
%=======================================================================

	`<`, `LIFNR`, `>`

	, wrap( buyers_code_for_buyer(d), `DEVINCI`, `` )

	, trace( [ `buyers_code_for_buyer`, buyers_code_for_buyer ] ) 
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER AND DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number_and_date, [ 
%=======================================================================

	q0n(line)

	, xml_tag_line( [ `E1EDK02` ] )

	, q10( [ q0n( line ), xml_tag_line( [ `BELNR`, order_number ] ) ] )

	, q10( [ q0n( line ), invoice_date_line ] )
] ).

%=======================================================================
i_line_rule( invoice_date_line, [
%=======================================================================

	`<`, `DATUM`, `>`

	, set( regexp_allow_partial_matching )

	, invoice_date(f([begin,q(dec,4,4),end]))

	, append( invoice_date(f([begin,q(dec,2,2),end])), `-`, `` )

	, append( invoice_date(f([begin,q(dec,2,2),end])), `-`, `` )

	, clear( regexp_allow_partial_matching )

	, trace( [ `invoice_date`, invoice_date ] )

] ).


%=======================================================================
i_line_rule( original_order_date_line, [
%=======================================================================

	`<`, `EDATU`, `>`

	, set( regexp_allow_partial_matching )

	, line_original_order_date(f([begin,q(dec,4,4),end]))

	, append( line_original_order_date(f([begin,q(dec,2,2),end])), `-`, `` )

	, append( line_original_order_date(f([begin,q(dec,2,2),end])), `-`, `` )

	, clear( regexp_allow_partial_matching )

	, trace( [ `line_date`, line_original_order_date ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	xml_tag_line( [ `E1EDP01` ] )

%	, q10( [ with( invoice, invoice_date, DATE ), line_original_order_date( DATE ) ] )

	, q0n( [

		or( [
			xml_tag_line( [ `POSEX`, line_order_line_number ] )

			, xml_tag_line( [ `MENGE`, line_quantity ] )

			, xml_tag_line( [ `MENEE`, line_quantity_uom_code ] )

			, xml_tag_line( [ `IDTNR`, line_item ] )

			, xml_tag_line( [ `KTEXT`, line_descr ] )

			, original_order_date_line

			, line
		] )
	] )

	, line_end_line
] ).

%=======================================================================
i_line_rule_cut( line_end_line, [ `<`, `/`, `E1EDP01`, `>` ] ).
%=======================================================================

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

	, `<`

	, trace( [ VARIABLE_NAME, VARIABLE ] )
] )

:-

	q_sys_is_atom( VARIABLE )
	
	, READ_VARIABLE =.. [ VARIABLE, s ]

	, READ_MORE_VARIABLE =.. [ append, READ_VARIABLE, ` `, `` ]

	, sys_string_atom( VARIABLE_NAME, VARIABLE )

. %end%

