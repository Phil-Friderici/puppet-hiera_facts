# @param options Configure fact(s) and path(s) details to be used by the backend.
# @param context We ignore this argument, it is mandatory for a function to accept it.
# @return [Hash] Returns a hash that contains all collected hiera data for the given configuration.
#
function hiera_facts::facts_backend(
  Hash                  $options,
  Puppet::LookupContext $context,
) >> Hash[RichDataKey, RichData] {

  if has_key($options, 'hierachies') {

    # itterate through the $options[hierachies] hash and collect the data
    # $values_data will result in an array containing all data as individial hashes
    $values_data = $options[hierachies].map |$_name, $hierachy| {

      # check data type and convert strings to array if needed
      $fact_values = getvar($hierachy[fact])
      case $fact_values {
        Array:   { $fact_values_array = $fact_values }
        String:  { $fact_values_array = split($fact_values, ',') }
        Undef:   { $fact_values_array = [] }
        default: { fail("The fact ${hierachy[fact]} is not an array nor a string") }
      }

      # iterate through the array of fact values to load the data for each value.
      # $value_data will result in an array containing all data as individual hashes
      $value_data = $fact_values_array.map |$value| {
        loadyaml("${hierachy[path]}/${value}.yaml", {})
      }

      # merge all individual hashes in array into one hash
      $fact_hash = $value_data.reduce( {} ) |$memo, $value_data| {
        $merged = deeper_merge($memo, $value_data)
        $merged
      }

      $fact_hash
    }

    # merge all individual hashes in array into one hash
    $hashes = $values_data.reduce( {} ) |$memo, $values_data| {
      $merged = deeper_merge($memo, $values_data)
      $merged
    }

    $hashes
  }
  else {
    {}
  }
}
