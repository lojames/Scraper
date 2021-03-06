# Sourced from lists of the most common first names and last names.  Generates
# a YAML file that is used by the UserGenerator class.

require 'yaml'

first_names = %Q(
JAMES	3.318	4,840,833	1
JOHN	3.271	4,772,262	2
ROBERT	3.143	4,585,515	3
MICHAEL	2.629	3,835,609	4
WILLIAM	2.451	3,575,914	5
DAVID	2.363	3,447,525	6
RICHARD	1.703	2,484,611	7
CHARLES	1.523	2,221,998	8
JOSEPH	1.404	2,048,382	9
THOMAS	1.38	2,013,366	10
CHRISTOPHER	1.035	1,510,025	11
DANIEL	0.974	1,421,028	12
PAUL	0.948	1,383,095	13
MARK	0.938	1,368,506	14
DONALD	0.931	1,358,293	15
GEORGE	0.927	1,352,457	16
KENNETH	0.826	1,205,102	17
STEVEN	0.78	1,137,990	18
EDWARD	0.779	1,136,531	19
BRIAN	0.736	1,073,795	20
RONALD	0.725	1,057,747	21
ANTHONY	0.721	1,051,911	22
KEVIN	0.671	978,963	23
JASON	0.66	962,914	24
MATTHEW	0.657	958,538	25
GARY	0.65	948,325	26
TIMOTHY	0.64	933,735	27
JOSE	0.613	894,343	28
LARRY	0.598	872,459	29
HENRY	0.365	532,521	46
MARY	2.629	3,991,060	1
PATRICIA	1.073	1,628,911	2
LINDA	1.035	1,571,224	3
BARBARA	0.98	1,487,729	4
ELIZABETH	0.937	1,422,451	5
JENNIFER	0.932	1,414,861	6
MARIA	0.828	1,256,979	7
SUSAN	0.794	1,205,364	8
MARGARET	0.768	1,165,894	9
DOROTHY	0.727	1,103,652	10
LISA	0.704	1,068,736	11
NANCY	0.669	1,015,603	12
KAREN	0.667	1,012,567	13
BETTY	0.666	1,011,048	14
HELEN	0.663	1,006,494	15
SANDRA	0.629	954,879	16
DONNA	0.583	885,047	17
CAROL	0.565	857,721	18
RUTH	0.562	853,167	19
SHARON	0.522	792,443	20
MICHELLE	0.519	787,889	21
LAURA	0.51	774,226	22
SARAH	0.508	771,190	23
KIMBERLY	0.504	765,118	24
DEBORAH	0.494	749,937	25
JESSICA	0.49	743,864	26
SHIRLEY	0.482	731,720	27
CYNTHIA	0.469	711,985	28
ANGELA	0.468	710,466	29
MELISSA	0.462	701,358	30
)

first_names = first_names.scan(/[A-Z]+/).map {|name| name.capitalize}



last_names = %Q(  1. Smith

  2. Johnson

  3. Williams

  4. Jones

  5. Brown

  6. Davis

  7. Miller

  8. Wilson

  9. Moore

  10. Taylor

  11. Anderson

  12. Thomas

  13. Jackson

  14. White

  15. Harris

  16. Martin

  17. Thompson

  18. Garcia

  19. Martinez

  20. Robinson

  21. Clark

  22. Rodriguez

  23. Lewis

  24. Lee

  25. Walker

  26. Hall

  27. Allen

  28. Young

  29. Hernandez

  30. King

  31. Wright

  32. Lopez

  33. Hill

  34. Scott

  35. Green

  36. Adams

  37. Baker

  38. Gonzalez

  39. Nelson

  40. Carter

  41. Mitchell

  42. Perez

  43. Roberts

  44. Turner

  45. Phillips

  46. Campbell

  47. Parker

  48. Evans

  49. Edwards

  50. Collins  )

last_names = last_names.scan(/[a-zA-Z]+/)

names = {
  first_names: first_names,
  last_names: last_names
}

puts names
file = File.open("names.yaml", "w")
file.write(names.to_yaml)
file.close
