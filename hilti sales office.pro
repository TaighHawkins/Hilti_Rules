%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - HILTI SALES OFFICE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( hilti_sales_office, `05 February 2015` ).

i_user_field( invoice, sales_office, `Sales Office` ).
custom_e1edk14_segment( `016`, sales_office ).

i_final_rule( [ 
	with( invoice, agent_code_3, Agent3 )
	
	, without( quotation_number )
	
	, check( i_user_check( assign_sales_office, Agent3, order, Sales ) )
	
	, sales_office( Sales )
	, trace( [ `Assigned to Sales Office`, Sales ] )
] ).

i_user_check( assign_sales_office, Agent3, Type, Sales )
:-
	sales_office_lookup( Agent3, Type, Sales )
.
	
sales_office_lookup( `4400`, order, `4410` ).
sales_office_lookup( `2600`, order, `2697` ).
sales_office_lookup( `2700`, order, `2797` ).
sales_office_lookup( `3300`, order, `3397` ).
sales_office_lookup( `4600`, order, `4697` ).
sales_office_lookup( `0900`, order, `1003` ).
sales_office_lookup( `7000`, order, `7097` ).
sales_office_lookup( `3100`, order, `3197` ).
sales_office_lookup( `3200`, order, `3297` ).
sales_office_lookup( `0800`, order, `0897` ).
sales_office_lookup( `0001`, order, `0097` ).
sales_office_lookup( `2100`, order, `2197` ).
sales_office_lookup( `5000`, order, `5911` ).
sales_office_lookup( `0700`, order, `0797` ).
sales_office_lookup( `7500`, order, `7809` ).
sales_office_lookup( `6000`, order, `6093` ).
sales_office_lookup( `6800`, order, `6893` ).
sales_office_lookup( `2500`, order, `2597` ).
sales_office_lookup( `2300`, order, `2395` ).
sales_office_lookup( `4400`, quotation, `4411` ).
sales_office_lookup( `2600`, quotation, `2696` ).
sales_office_lookup( `2700`, quotation, `2796` ).
sales_office_lookup( `3300`, quotation, `3396` ).
sales_office_lookup( `4600`, quotation, `4696` ).
sales_office_lookup( `0900`, quotation, `1004` ).
sales_office_lookup( `7000`, quotation, `7096` ).
sales_office_lookup( `3200`, quotation, `3296` ).
sales_office_lookup( `0800`, quotation, `0894` ).
sales_office_lookup( `0001`, quotation, `0096` ).
sales_office_lookup( `2100`, quotation, `2196` ).
sales_office_lookup( `5000`, quotation, `5912` ).
sales_office_lookup( `0700`, quotation, `0794` ).
sales_office_lookup( `7500`, quotation, `7808` ).
sales_office_lookup( `6000`, quotation, `6092` ).
sales_office_lookup( `6800`, quotation, `6892` ).
sales_office_lookup( `2500`, quotation, `2596` ).