// file: core/math/aabb.h
// commit: 7ad14e7a3e6f87ddc450f7e34621eb5200808451
// file: core/math/aabb.cpp
// commit: bd282ff43f23fe845f29a3e25c8efc01bd65ffb0
// file: core/variant_call.cpp
// commit: 5ad9be4c24e9d7dc5672fdc42cea896622fe5685
using System;
#if REAL_T_IS_DOUBLE
using real_t = System.Double;
#else
using real_t = System.Single;
#endif

namespace Godot
{
    public struct AABB : IEquatable<AABB>
    {
        private Vector3 position;
        private Vector3 size;

        public Vector3 Position
        {
            get
            {
                return position;
            }
        }

        public Vector3 Size
        {
            get
            {
                return size;
            }
        }

        public Vector3 End
        {
            get
            {
                return position + size;
            }
        }

        public bool Encloses(AABB with)
        {
            Vector3 src_min = position;
            Vector3 src_max = position + size;
            Vector3 dst_min = with.position;
            Vector3 dst_max = with.position + with.size;

            return src_min.x <= dst_min.x &&
                   src_max.x > dst_max.x &&
                   src_min.y <= dst_min.y &&
                   src_max.y > dst_max.y &&
                   src_min.z <= dst_min.z &&
                   src_max.z > dst_max.z;
        }

        public AABB Expand(Vector3 to_point)
        {
            Vector3 begin = position;
            Vector3 end = position + size;

            if (to_point.x < begin.x)
                begin.x = to_point.x;
            if (to_point.y < begin.y)
                begin.y = to_point.y;
            if (to_point.z < begin.z)
                begin.z = to_point.z;

            if (to_point.x > end.x)
                end.x = to_point.x;
            if (to_point.y > end.y)
                end.y = to_point.y;
            if (to_point.z > end.z)
                end.z = to_point.z;

            return new AABB(begin, end - begin);
        }

        public real_t GetArea()
        {
            return size.x * size.y * size.z;
        }

        public Vector3 GetEndpoint(int idx)
        {
            switch (idx)
            {
                case 0:
                    return new Vector3(position.x, position.y, position.z);
                case 1:
                    return new Vector3(position.x, position.y, position.z + size.z);
                case 2:
                    return new Vector3(position.x, position.y + size.y, position.z);
                case 3:
                    return new Vector3(position.x, position.y + size.y, position.z + size.z);
                case 4:
                    return new Vector3(position.x + size.x, position.y, position.z);
                case 5:
                    return new Vector3(position.x + size.x, position.y, position.z + size.z);
                case 6:
                    return new Vector3(position.x + size.x, position.y + size.y, position.z);
                case 7:
                    return new Vector3(position.x + size.x, position.y + size.y, position.z + size.z);
                default:
                    throw new ArgumentOutOfRangeException(nameof(idx), String.Format("Index is {0}, but a value from 0 to 7 is expected.", idx));
            }
        }

        public Vector3 GetLongestAxis()
        {
            var axis = new Vector3(1f, 0f, 0f);
            real_t max_size = size.x;

            if (size.y > max_size)
            {
                axis = new Vector3(0f, 1f, 0f);
                max_size = size.y;
            }

            if (size.z > max_size)
            {
                axis = new Vector3(0f, 0f, 1f);
            }

            return axis;
        }

        public Vector3.Axis GetLongestAxisIndex()
        {
            var axis = Vector3.Axis.X;
            real_t max_size = size.x;

            if (size.y > max_size)
            {
                axis = Vector3.Axis.Y;
                max_size = size.y;
            }

            if (size.z > max_size)
            {
                axis = Vector3.Axis.Z;
            }

            return axis;
        }

        public real_t GetLongestAxisSize()
        {
            real_t max_size = size.x;

            if (size.y > max_size)
                max_size = size.y;

            if (size.z > max_size)
                max_size = size.z;

            return max_size;
        }

        public Vector3 GetShortestAxis()
        {
            var axis = new Vector3(1f, 0f, 0f);
            real_t max_size = size.x;

            if (size.y < max_size)
            {
                axis = new Vector3(0f, 1f, 0f);
                max_size = size.y;
            }

            if (size.z < max_size)
            {
                axis = new Vector3(0f, 0f, 1f);
            }

            return axis;
        }

        public Vector3.Axis GetShortestAxisIndex()
        {
            var axis = Vector3.Axis.X;
            real_t max_size = size.x;

            if (size.y < max_size)
            {
                axis = Vector3.Axis.Y;
                max_size = size.y;
            }

            if (size.z < max_size)
            {
                axis = Vector3.Axis.Z;
            }

            return axis;
        }

        public real_t GetShortestAxisSize()
        {
            real_t max_size = size.x;

            if (size.y < max_size)
                max_size = size.y;

            if (size.z < max_size)
                max_size = size.z;

            return max_size;
        }

        public Vector3 GetSupport(Vector3 dir)
        {
            Vector3 half_extents = size * 0.5f;
            Vector3 ofs = position + half_extents;

            return ofs + new Vector3(
                dir.x > 0f ? -half_extents.x : half_extents.x,
                dir.y > 0f ? -half_extents.y : half_extents.y,
                dir.z > 0f ? -half_extents.z : half_extents.z);
        }

        public AABB Grow(real_t by)
        {
            var res = this;

            res.position.x -= by;
            res.position.y -= by;
            res.position.z -= by;
            res.size.x += 2.0f * by;
            res.size.y += 2.0f * by;
            res.size.z += 2.0f * by;

            return res;
        }

        public bool HasNoArea()
        {
            return size.x <= 0f || size.y <= 0f || size.z <= 0f;
        }

        public bool HasNoSurface()
        {
            return size.x <= 0f && size.y <= 0f && size.z <= 0f;
        }

        public bool HasPoint(Vector3 point)
        {
            if (point.x < position.x)
                return false;
            if (point.y < position.y)
                return false;
            if (point.z < position.z)
                return false;
            if (point.x > position.x + size.x)
                return false;
            if (point.y > position.y + size.y)
                return false;
            if (point.z > position.z + size.z)
                return false;

            return true;
        }

        public AABB Intersection(AABB with)
        {
            Vector3 src_min = position;
            Vector3 src_max = position + size;
            Vector3 dst_min = with.position;
            Vector3 dst_max = with.position + with.size;

            Vector3 min, max;

            if (src_min.x > dst_max.x || src_max.x < dst_min.x)
            {
                return new AABB();
            }

            min.x = src_min.x > dst_min.x ? src_min.x : dst_min.x;
            max.x = src_max.x < dst_max.x ? src_max.x : dst_max.x;

            if (src_min.y > dst_max.y || src_max.y < dst_min.y)
            {
                return new AABB();
            }

            min.y = src_min.y > dst_min.y ? src_min.y : dst_min.y;
            max.y = src_max.y < dst_max.y ? src_max.y : dst_max.y;

            if (src_min.z > dst_max.z || src_max.z < dst_min.z)
            {
                return new AABB();
            }

            min.z = src_min.z > dst_min.z ? src_min.z : dst_min.z;
            max.z = src_max.z < dst_max.z ? src_max.z : dst_max.z;

            return new AABB(min, max - min);
        }

        public bool Intersects(AABB with)
        {
            if (position.x >= with.position.x + with.size.x)
                return false;
            if (position.x + size.x <= with.position.x)
                return false;
            if (position.y >= with.position.y + with.size.y)
                return false;
            if (position.y + size.y <= with.position.y)
                return false;
            if (position.z >= with.position.z + with.size.z)
                return false;
            if (position.z + size.z <= with.position.z)
                return false;

            return true;
        }

        public bool IntersectsPlane(Plane plane)
        {
            Vector3[] points =
            {
                new Vector3(position.x, position.y, position.z),
                new Vector3(position.x, position.y, position.z + size.z),
                new Vector3(position.x, position.y + size.y, position.z),
                new Vector3(position.x, position.y + size.y, position.z + size.z),
                new Vector3(position.x + size.x, position.y, position.z),
                new Vector3(position.x + size.x, position.y, position.z + size.z),
                new Vector3(position.x + size.x, position.y + size.y, position.z),
                new Vector3(position.x + size.x, position.y + size.y, position.z + size.z)
            };

            bool over = false;
            bool under = false;

            for (int i = 0; i < 8; i++)
            {
                if (plane.DistanceTo(points[i]) > 0)
                    over = true;
                else
                    under = true;
            }

            return under && over;
        }

        public bool IntersectsSegment(Vector3 from, Vector3 to)
        {
            real_t min = 0f;
            real_t max = 1f;

            for (int i = 0; i < 3; i++)
            {
                real_t seg_from = from[i];
                real_t seg_to = to[i];
                real_t box_begin = position[i];
                real_t box_end = box_begin + size[i];
                real_t cmin, cmax;

                if (seg_from < seg_to)
                {
                    if (seg_from > box_end || seg_to < box_begin)
                        return false;

                    real_t length = seg_to - seg_from;
                    cmin = seg_from < box_begin ? (box_begin - seg_from) / length : 0f;
                    cmax = seg_to > box_end ? (box_end - seg_from) / length : 1f;
                }
                else
                {
                    if (seg_to > box_end || seg_from < box_begin)
                        return false;

                    real_t length = seg_to - seg_from;
                    cmin = seg_from > box_end ? (box_end - seg_from) / length : 0f;
                    cmax = seg_to < box_begin ? (box_begin - seg_from) / length : 1f;
                }

                if (cmin > min)
                {
                    min = cmin;
                }

                if (cmax < max)
                    max = cmax;
                if (max < min)
                    return false;
            }

            return true;
        }

        public AABB Merge(AABB with)
        {
            Vector3 beg_1 = position;
            Vector3 beg_2 = with.position;
            var end_1 = new Vector3(size.x, size.y, size.z) + beg_1;
            var end_2 = new Vector3(with.size.x, with.size.y, with.size.z) + beg_2;

            var min = new Vector3(
                              beg_1.x < beg_2.x ? beg_1.x : beg_2.x,
                              beg_1.y < beg_2.y ? beg_1.y : beg_2.y,
                              beg_1.z < beg_2.z ? beg_1.z : beg_2.z
                          );

            var max = new Vector3(
                              end_1.x > end_2.x ? end_1.x : end_2.x,
                              end_1.y > end_2.y ? end_1.y : end_2.y,
                              end_1.z > end_2.z ? end_1.z : end_2.z
                          );

            return new AABB(min, max - min);
        }
        
        // Constructors 
        public AABB(Vector3 position, Vector3 size)
        {
            this.position = position;
            this.size = size;
        }

        public static bool operator ==(AABB left, AABB right)
        {
            return left.Equals(right);
        }

        public static bool operator !=(AABB left, AABB right)
        {
            return !left.Equals(right);
        }

        public override bool Equals(object obj)
        {
            if (obj is AABB)
            {
                return Equals((AABB)obj);
            }

            return false;
        }

        public bool Equals(AABB other)
        {
            return position == other.position && size == other.size;
        }

        public override int GetHashCode()
        {
            return position.GetHashCode() ^ size.GetHashCode();
        }

        public override string ToString()
        {
            return String.Format("{0} - {1}", new object[]
                {
                    position.ToString(),
                    size.ToString()
                });
        }

        public string ToString(string format)
        {
            return String.Format("{0} - {1}", new object[]
                {
                    position.ToString(format),
                    size.ToString(format)
                });
        }
    }
}
